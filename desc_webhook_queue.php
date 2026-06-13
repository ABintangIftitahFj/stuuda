<?php
header('Content-Type: application/json');
$conn = new mysqli('localhost', 'stundaac_whatsjet1', '8YvN4cmMYLhdyQG9VjHL', 'stundaac_whatsjet');
$res = $conn->query("DESCRIBE whatsapp_webhook_queue");
$cols = [];
while($row = $res->fetch_assoc()) { $cols[] = $row; }
echo json_encode($cols, JSON_PRETTY_PRINT);
?>
