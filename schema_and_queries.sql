-- =========================================================================
-- CRICKET TOURNAMENT MANAGEMENT SYSTEM
-- AUTHOR: Shubham Sanjay Patra
-- DESCRIPTION: Database Schema, Mock Data, and Performance Analytics Queries
-- =========================================================================

-- 1. DATABASE CREATION & SETUP
CREATE DATABASE IF NOT EXISTS CricketTournament;
USE CricketTournament;

-- Drop tables if they exist to allow clean re-runs
DROP TABLE IF EXISTS MatchPerformances;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Teams;

-- 2. TABLE CREATION (Relational Schema)
CREATE TABLE Teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(50) NOT NULL UNIQUE,
    coach VARCHAR(50),
    home_ground VARCHAR(100)
);

CREATE TABLE Players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(50) NOT NULL,
    team_id INT,
    role VARCHAR(30) CHECK (role IN ('Batsman', 'Bowler', 'All-Rounder', 'Wicket-Keeper')),
    age INT,
    FOREIGN KEY (team_id) REFERENCES Teams(team_id) ON DELETE SET NULL
);

CREATE TABLE MatchPerformances (
    performance_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT,
    match_date DATE NOT NULL,
    runs_scored INT DEFAULT 0,
    balls_faced INT DEFAULT 0,
    wickets_taken INT DEFAULT 0,
    overs_bowled DECIMAL(3,1) DEFAULT 0.0,
    runs_conceded INT DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES Players(player_id) ON DELETE CASCADE
);

-- 3. DATA INSERTION (Mock Records)
INSERT INTO Teams (team_name, coach, home_ground) VALUES
('Mumbai Mavericks', 'Mahela J.', 'Wankhede Stadium'),
('Delhi Dynamos', 'Ricky P.', 'Arun Jaitley Stadium'),
('Chennai Kings', 'Stephen F.', 'M.A. Chidambaram Stadium');

INSERT INTO Players (player_name, team_id, role, age) VALUES
('Rohit Sharma', 1, 'Batsman', 36),
('Jasprit Bumrah', 1, 'Bowler', 30),
('Rishabh Pant', 2, 'Wicket-Keeper', 26),
('Axar Patel', 2, 'All-Rounder', 30),
('Ravindra Jadeja', 3, 'All-Rounder', 35);

INSERT INTO MatchPerformances (player_id, match_date, runs_scored, balls_faced, wickets_taken, overs_bowled, runs_conceded) VALUES
(1, '2026-04-01', 75, 45, 0, 0.0, 0),
(2, '2026-04-01', 5, 3, 3, 4.0, 22),
(3, '2026-04-02', 48, 28, 0, 0.0, 0),
(4, '2026-04-02', 22, 15, 1, 3.0, 18),
(5, '2026-04-03', 35, 20, 2, 4.0, 25),
(1, '2026-04-10', 12, 8, 0, 0.0, 0);

-- 4. ANALYTICAL QUERIES (Portfolio Showcases)

-- Query A: Comprehensive Player Profile with Team Details (INNER JOIN)
SELECT p.player_name, t.team_name, p.role, p.age
FROM Players p
INNER JOIN Teams t ON p.team_id = t.team_id;

-- Query B: Top Batsmen Ranked by Total Runs and Batting Strike Rate
SELECT 
    p.player_name,
    t.team_name,
    SUM(m.runs_scored) AS total_runs,
    ROUND((SUM(m.runs_scored) / NULLIF(SUM(m.balls_faced), 0)) * 100, 2) AS batting_strike_rate
FROM Players p
JOIN Teams t ON p.team_id = t.team_id
JOIN MatchPerformances m ON p.player_id = m.player_id
GROUP BY p.player_id, p.player_name, t.team_name
HAVING total_runs > 0
ORDER BY total_runs DESC;

-- Query C: Bowling Efficiency Metrics (Economy Rate)
SELECT 
    p.player_name,
    SUM(m.wickets_taken) AS total_wickets,
    SUM(m.overs_bowled) AS total_overs,
    ROUND(SUM(m.runs_conceded) / NULLIF(SUM(m.overs_bowled), 0), 2) AS economy_rate
FROM Players p
JOIN MatchPerformances m ON p.player_id = m.player_id
WHERE p.role IN ('Bowler', 'All-Rounder')
GROUP BY p.player_id, p.player_name
ORDER BY total_wickets DESC, economy_rate ASC;