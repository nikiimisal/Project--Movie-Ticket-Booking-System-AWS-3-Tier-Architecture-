<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Database configuration (replace with your RDS details)
define('DB_HOST', 'your-rds-endpoint.rds.amazonaws.com');
define('DB_NAME', 'movie_booking_db');
define('DB_USER', 'admin');
define('DB_PASS', 'your-password');

// Create connection
try {
    $pdo = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Database connection failed: " . $e->getMessage()]);
    exit;
}

// Handle the request
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'POST') {
    // Handle booking submission
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['movie']) || !isset($input['showtime']) || !isset($input['date']) || 
        !isset($input['seats']) || !isset($input['name']) || !isset($input['email']) || 
        !isset($input['phone']) || !isset($input['payment'])) {
        http_response_code(400);
        echo json_encode(["message" => "Missing required fields"]);
        exit;
    }
    
    try {
        // Generate a unique booking ID
        $booking_id = 'BK' . uniqid();
        
        // Insert booking into database
        $stmt = $pdo->prepare("INSERT INTO bookings (booking_id, movie_id, showtime, booking_date, seats, customer_name, customer_email, customer_phone, payment_method) 
                              VALUES (:booking_id, :movie_id, :showtime, :booking_date, :seats, :customer_name, :customer_email, :customer_phone, :payment_method)");
        
        $stmt->execute([
            ':booking_id' => $booking_id,
            ':movie_id' => $input['movie'],
            ':showtime' => $input['showtime'],
            ':booking_date' => $input['date'],
            ':seats' => $input['seats'],
            ':customer_name' => $input['name'],
            ':customer_email' => $input['email'],
            ':customer_phone' => $input['phone'],
            ':payment_method' => $input['payment']
        ]);
        
        // Get movie title
        $stmt = $pdo->prepare("SELECT title FROM movies WHERE id = :movie_id");
        $stmt->execute([':movie_id' => $input['movie']]);
        $movie = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // In a real application, you would send a confirmation email here
        
        http_response_code(201);
        echo json_encode([
            "message" => "Booking confirmed successfully",
            "booking_id" => $booking_id,
            "details" => [
                "movie" => $movie['title'],
                "showtime" => $input['showtime'],
                "date" => $input['date'],
                "seats" => $input['seats'],
                "name" => $input['name'],
                "email" => $input['email']
            ]
        ]);
        
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["message" => "Booking failed: " . $e->getMessage()]);
    }
    
} elseif ($method == 'GET') {
    // Handle GET requests (fetch movies)
    try {
        $stmt = $pdo->prepare("SELECT id, title, genre, duration, poster_url FROM movies WHERE NOW() < release_date + INTERVAL 30 DAY");
        $stmt->execute();
        $movies = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode($movies);
        
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(["message" => "Failed to fetch movies: " . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(["message" => "Method not allowed"]);
}
?>
