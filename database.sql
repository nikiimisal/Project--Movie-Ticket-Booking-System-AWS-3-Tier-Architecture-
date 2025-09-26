-- Create database
CREATE DATABASE IF NOT EXISTS movie_booking_db;
USE movie_booking_db;

-- Movies table
CREATE TABLE movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    genre VARCHAR(100),
    duration VARCHAR(50),
    release_date DATE,
    poster_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookings table
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id VARCHAR(50) UNIQUE NOT NULL,
    movie_id INT NOT NULL,
    showtime VARCHAR(50) NOT NULL,
    booking_date DATE NOT NULL,
    seats INT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (movie_id) REFERENCES movies(id)
);

-- Insert sample movies
INSERT INTO movies (title, description, genre, duration, release_date, poster_url) VALUES
('Avatar: The Way of Water', 'Jake Sully lives with his newfound family formed on the planet of Pandora. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri and the army of the Na''vi race to protect their planet.', 'Sci-Fi', '3h 12m', '2022-12-16', 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'),
('Black Panther: Wakanda Forever', 'The people of Wakanda fight to protect their home from intervening world powers as they mourn the death of King T''Challa.', 'Action', '2h 41m', '2022-11-11', 'https://images.unsplash.com/photo-1594909122845-11baa439b7bf?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'),
('The Batman', 'When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate the city''s hidden corruption and question his family''s involvement.', 'Action', '2h 56m', '2022-03-04', 'https://images.unsplash.com/photo-1489599102910-59206b8ca314?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'),
('Top Gun: Maverick', 'After thirty years, Maverick is still pushing the envelope as a top naval aviator, but must confront ghosts of his past when he leads TOP GUN''s elite graduates on a mission that demands the ultimate sacrifice from those chosen to fly it.', 'Action', '2h 10m', '2022-05-27', 'https://images.unsplash.com/photo-1596727147705-61a532a659bd?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'),
('Jurassic World Dominion', 'Four years after the destruction of Isla Nublar, dinosaurs now live and hunt alongside humans all over the world. This fragile balance will reshape the future and determine, once and for all, whether human beings are to remain the apex predators on a planet they now share with history''s most fearsome creatures.', 'Adventure', '2h 27m', '2022-06-10', 'https://images.unsplash.com/photo-1598899134739-24c46f58b8c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80'),
('Doctor Strange in the Multiverse of Madness', 'Doctor Strange teams up with a mysterious teenage girl from his dreams who can travel across multiverses, to battle multiple threats, including other-universe versions of himself, which threaten to wipe out millions across the multiverse.', 'Fantasy', '2h 6m', '2022-05-06', 'https://images.unsplash.com/photo-1635805737707-575885ab0820?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80');
