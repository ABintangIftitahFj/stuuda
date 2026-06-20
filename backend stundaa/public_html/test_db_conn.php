<?php
header('Content-Type: text/plain');

$configs = [
    [
        'label' => 'Opsi A (env_x.md default)',
        'host' => '127.0.0.1',
        'user' => 'stundaac_whatsjet1',
        'pass' => '8YvN4cmMYLhdyQG9VjHL',
        'db'   => 'stundaac_whatsjet'
    ],
    [
        'label' => 'Opsi B (User stundaac)',
        'host' => '127.0.0.1',
        'user' => 'stundaac',
        'pass' => 'x4Ir4o)An24L-H',
        'db'   => 'stundaac_whatsjet'
    ],
    [
        'label' => 'Opsi C (Host localhost)',
        'host' => 'localhost',
        'user' => 'stundaac_whatsjet1',
        'pass' => '8YvN4cmMYLhdyQG9VjHL',
        'db'   => 'stundaac_whatsjet'
    ]
];

foreach ($configs as $c) {
    echo "Testing {$c['label']}...\n";
    try {
        $conn = new mysqli($c['host'], $c['user'], $c['pass'], $c['db']);
        if ($conn->connect_error) {
            echo "FAILED: " . $conn->connect_error . "\n";
        } else {
            echo "SUCCESS!\n";
            $conn->close();
        }
    } catch (Exception $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
    echo "--------------------------\n";
}
?>