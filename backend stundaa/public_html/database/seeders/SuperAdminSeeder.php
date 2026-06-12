<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = 'superadmin@stundaa.com';
        $password = 'Admin@Stundaa2024!';

        $exists = DB::table('users')->where('email', $email)->exists();

        if (!$exists) {
            DB::table('users')->insert([
                '_uid'           => Str::uuid()->toString(),
                'first_name'     => 'Super',
                'last_name'      => 'Admin',
                'email'          => $email,
                'password'       => Hash::make($password),
                'status'         => 1,
                'user_roles__id' => 1,
                'created_at'     => now(),
                'updated_at'     => now(),
            ]);
            $this->command->info("SuperAdmin created: {$email} / {$password}");
        } else {
            // Reset password if already exists
            DB::table('users')->where('email', $email)->update([
                'password'   => Hash::make($password),
                'status'     => 1,
                'updated_at' => now(),
            ]);
            $this->command->info("SuperAdmin password reset: {$email} / {$password}");
        }
    }
}
