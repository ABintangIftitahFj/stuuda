<?php
/**
 * WhatsJet
 *
 * This file is part of the WhatsJet software package developed and licensed by livelyworks.
 *
 * You must have a valid license to use this software.
 *
 * © 2024 - 2026 livelyworks. All rights reserved.
 * Redistribution or resale of this file, in whole or in part, is prohibited without prior written permission from the author.
 *
 * For support or inquiries, contact: contact@livelyworks.net
 *
 * @package     WhatsJet
 * @author      livelyworks <contact@livelyworks.net>
 * @copyright   Copyright (c) 2024 - 2026 livelyworks
 * @website     https://livelyworks.net
 */

// Simpan sebagai suntik_bahasa.php di folder public_html server kamu
// Panggil lewat browser: https://stundaa.com/suntik_bahasa.php

require 'bootstrap/autoload.php';
$app = require_once 'bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->handle(Illuminate\Http\Request::capture());

use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

echo "Memulai suntik bahasa Indonesia...<br>";

$now = Carbon::now();
$langId = 'id';
$langName = 'Indonesian';

// Ambil data lama
$config = DB::table('configurations')->where('name', 'translation_languages')->first();

if ($config) {
    $currentLangs = json_decode($config->value, true) ?: [];
    if (!isset($currentLangs[$langId])) {
        $currentLangs[$langId] = [
            'id' => $langId,
            'name' => $langName,
            'status' => true,
            'created_at' => $now->toDateTimeString(),
            'updated_at' => $now->toDateTimeString()
        ];
        
        DB::table('configurations')
            ->where('name', 'translation_languages')
            ->update(['value' => json_encode($currentLangs), 'updated_at' => $now]);
        echo "Berhasil MENAMBAHKAN Bahasa Indonesia ke database.";
    } else {
        echo "Bahasa Indonesia SUDAH ADA di database.";
    }
} else {
    // Jika barisnya belum ada sama sekali
    $newLangs = [
        $langId => [
            'id' => $langId,
            'name' => $langName,
            'status' => true,
            'created_at' => $now->toDateTimeString(),
            'updated_at' => $now->toDateTimeString()
        ]
    ];
    
    DB::table('configurations')->insert([
        'name' => 'translation_languages',
        'value' => json_encode($newLangs),
        'data_type' => 4, // Biasanya 4 untuk JSON/Array di sistem ini
        'created_at' => $now,
        'updated_at' => $now
    ]);
    echo "Berhasil MEMBUAT baris konfigurasi bahasa dan menambahkan Bahasa Indonesia.";
}
?>
