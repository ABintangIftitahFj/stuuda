<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Yantrana\Components\WhatsAppService\Repositories\WhatsAppMessageLogRepository;
use App\Yantrana\Components\WhatsAppService\Services\WhatsAppApiService;
use App\Yantrana\Components\Media\MediaEngine;
use App\Yantrana\Components\WhatsAppService\Models\WhatsAppMessageLogModel;
use Illuminate\Support\Arr;

class DownloadWhatsAppMedia extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'whatsapp:media:download';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Download pending WhatsApp media files';

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $pendingLogs = WhatsAppMessageLogModel::where('__data->media_values->is_download_pending', true)
            ->limit(10)
            ->get();

        if ($pendingLogs->isEmpty()) {
            $this->info('No pending media downloads found.');
            return 0;
        }

        $whatsAppApiService = app(WhatsAppApiService::class);
        $mediaEngine = app(MediaEngine::class);

        foreach ($pendingLogs as $log) {
            $this->info("Processing Log ID: {$log->_id}");
            $data = $log->__data;
            $mediaValues = $data['media_values'];
            
            $mediaId = $mediaValues['media_id'];
            $vendorId = $log->vendors__id;
            $mediaType = $mediaValues['type'];
            
            // Get vendor UID
            $vendorUid = getPublicVendorUid($vendorId);

            try {
                $downloadedFileInfo = $mediaEngine->downloadAndStoreMediaFile(
                    $whatsAppApiService->downloadMedia($mediaId, $vendorId),
                    $vendorUid,
                    $mediaType
                );

                $mediaValues = array_merge($mediaValues, [
                    'link' => Arr::get($downloadedFileInfo, 'path'),
                    'file_name' => Arr::get($downloadedFileInfo, 'fileName'),
                    'original_filename' => Arr::get($downloadedFileInfo, 'fileName'),
                ]);
                unset($mediaValues['is_download_pending']);

                $data['media_values'] = $mediaValues;
                $log->__data = $data;
                $log->save();

                $this->info("Successfully downloaded media for Log ID: {$log->_id}");
            } catch (\Exception $e) {
                $this->error("Failed to download media for Log ID: {$log->_id}. Error: " . $e->getMessage());
                // Optionally mark as failed or retry later
            }
        }

        return 0;
    }
}
