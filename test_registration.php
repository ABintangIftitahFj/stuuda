<?php
require __DIR__ . '/backend stundaa/public_html/vendor/autoload.php';
$app = require_once __DIR__ . '/backend stundaa/public_html/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\Validator;

$data = [
    'vendor_title' => 'My Vendor',
    'username' => 'hiangker',
    'first_name' => 'hiang',
    'last_name' => 'ker',
    'email' => 'hiangker@example.com',
    'password' => 'password123',
    'password_confirmation' => 'password123',
    'terms_and_conditions' => 'on'
];

$rules = [
    'vendor_title' => 'required|min:2|max:60',
    'username' => 'required|string|unique:users|alpha_dash|min:2|max:45',
    'first_name' => 'required|min:2|max:45',
    'last_name' => 'required|min:2|max:45',
    'email' => 'required|email|unique:users',
    'password' => 'required|min:8|max:30|confirmed',
    'terms_and_conditions' => 'required'
];

$validator = Validator::make($data, $rules);

if ($validator->fails()) {
    echo json_encode($validator->errors(), JSON_PRETTY_PRINT);
} else {
    echo "Validation passed!";
}
?>