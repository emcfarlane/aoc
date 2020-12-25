use std::env;
use std::fs;
use std::io::{self, BufRead};
use std::iter::FromIterator;

struct Point {
    x: i32,
    y: i32,
}

struct Ship {
    direction: i32, // 0..4
    north: i32,
    east: i32,
    north_waypoint: i32,
    east_waypoint: i32,
}

impl Ship {
    // Part1
    fn pilot(&mut self, cmd: char, num: i32) {
        match cmd {
            'N' => self.north += num,
            'S' => self.north -= num,
            'E' => self.east += num,
            'W' => self.east -= num,
            'R' => self.direction += num,
            'L' => self.direction -= num,
            'F' => match self.direction % 360 {
                0 => self.north += num,
                90 | -270 => self.east += num,
                180 | -180 => self.north -= num,
                270 | -90 => self.east -= num,
                _ => unreachable!(),
            },
            _ => (),
        }
    }

    // Part2
    fn pilot_waypoint(&mut self, cmd: char, num: i32) {
        match cmd {
            'N' => self.north_waypoint += num,
            'S' => self.north_waypoint -= num,
            'E' => self.east_waypoint += num,
            'W' => self.east_waypoint -= num,
            'R' | 'L' => {
                let mut num = num;
                if cmd == 'L' {
                    num = -num;
                }
                let north = self.north_waypoint;
                let east = self.east_waypoint;
                match num % 360 {
                    0 => (),
                    90 | -270 => {
                        self.east_waypoint = north;
                        self.north_waypoint = -east;
                    }
                    180 | -180 => {
                        self.east_waypoint = -east;
                        self.north_waypoint = -north;
                    }
                    270 | -90 => {
                        self.east_waypoint = -north;
                        self.north_waypoint = east;
                    }
                    _ => unreachable!(),
                };
            }
            'F' => {
                self.north += self.north_waypoint * num;
                self.east += self.east_waypoint * num;
            }
            _ => (),
        }
    }
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut ship = Ship {
        direction: 90, // east
        north: 0,
        east: 0,
        north_waypoint: 1,
        east_waypoint: 10,
    };

    for line in lines {
        let s = line?;

        let mut chars = s.chars();
        let cmd = chars.next().unwrap();
        let num: i32 = String::from_iter(chars).parse().unwrap();

        ship.pilot_waypoint(cmd, num);
    }
    println!(
        "distance {} + {} = {}",
        ship.east.abs(),
        ship.north.abs(),
        ship.east.abs() + ship.north.abs(),
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        assert_eq!(1, 2);
    }
}
