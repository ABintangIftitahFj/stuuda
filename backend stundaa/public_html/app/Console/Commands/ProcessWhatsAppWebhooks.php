<?php
// app/Console/Commands/ProcessWhatsAppWebhooks.php
namespace App\Console\Commands;

use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Console\Command;
use Symfony\Component\HttpFoundation\HeaderBag;
use App\Yantrana\Components\WhatsAppService\WhatsAppServiceEngine;
use App\Yantrana\Components\WhatsAppService\Models\WhatsAppWebhookModel;

class ProcessWhatsAppWebhooks extends Command
{
    protected $signature = 'whatsapp:webhooks:process {--webhooksCount=100}';
    protected $description = 'Process pending webhooks';
    public function handle()
    {
        $webhooksCount = $this->option('webhooksCount') ?: 100;
        WhatsAppWebhookModel::where('status', 'pending')
            ->where(function ($q) {
                $q->whereNull('attempted_at')
                  ->orWhereRaw('attempted_at < DATE_SUB(NOW(), INTERVAL POW(2, IFNULL(attempts, 0)) MINUTE)'); // Exponential backoff: 1, 2, 4, 8, 16 mins
            })
            ->latest()
            ->limit($webhooksCount)
            ->get()
            ->each(function ($webhook) {
                try {
                    // if attempted 5 times or created more than 2 days ago, mark as failed
                    if (($webhook->attempts >= 5) || ($webhook->created_at->copy()->addDays(2)->isPast())) {
                        $webhook->update([
                            'status' => 'failed',
                            'attempted_at' => now(),
                        ]);
                    } else {
                        $request = new Request(
                            query: [],
                            request: $webhook->payload,
                            attributes: [],
                            cookies: [],
                            files: [],
                            server: [],
                            content: json_encode($webhook->payload)
                        );
                        $request->headers = new HeaderBag($webhook->headers);
                        app()->make(WhatsAppServiceEngine::class)->processWebhookRequest($request, $webhook->vendors__id);
                        $webhook->delete();
                    }
                } catch (\Throwable $e) {
                    $errorMessage = trim($e->getMessage());
                    \Log::error('Webhook processing error: ' . $errorMessage);
                    if (str_starts_with($errorMessage, 'Unsupported')) {
                        $webhook->delete();
                    } else {
                        $webhook->update([
                            'status' => 'pending',
                            'attempted_at' => now(),
                            'attempts' => ($webhook->attempts ?? 0) + 1,
                        ]);
                    }
                }
            });
    }
}
