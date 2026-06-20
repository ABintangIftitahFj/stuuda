<?php
// Simple DB check to avoid Laravel overhead during debugging
header('Content-Type: text/plain');

$host = '127.0.0.1';
$user = 'stundaac_whatsjet1';
$pass = '8YvN4cmMYLhdyQG9VjHL';
$db   = 'stundaac_whatsjet';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo "Connected successfully to DB\n";

$langId = 'id';
$langName = 'Indonesian';
$now = date('Y-m-d H:i:s');

$sql = "SELECT * FROM configurations WHERE name = 'translation_languages'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $currentLangs = json_decode($row['value'], true) ?: [];
    if (!isset($currentLangs[$langId])) {
        $currentLangs[$langId] = [
            'id' => $langId,
            'name' => $langName,
            'status' => true,
            'created_at' => $now,
            'updated_at' => $now
        ];
        $newValue = json_encode($currentLangs);
        $updateSql = "UPDATE configurations SET value = ?, updated_at = ? WHERE name = 'translation_languages'";
        $stmt = $conn->prepare($updateSql);
        $stmt->bind_param("ss", $newValue, $now);
        $stmt->execute();
        echo "SUCCESS: Added Indonesian to existing configurations.\n";
    } else {
        echo "ALREADY EXISTS: Indonesian language is already there.\n";
    }
} else {
    $newLangs = [
        $langId => [
            'id' => $langId,
            'name' => $langName,
            'status' => true,
            'created_at' => $now,
            'updated_at' => $now
        ]
    ];
    $newValue = json_encode($newLangs);
    $insertSql = "INSERT INTO configurations (name, value, data_type, created_at, updated_at) VALUES (?, ?, 4, ?, ?)";
    $stmt = $conn->prepare($insertSql);
    $stmt->bind_param("ssss", $name = 'translation_languages', $newValue, $now, $now);
    $stmt->execute();
    echo "SUCCESS: Created configuration and added Indonesian.\n";
}

$conn->close();
?>
