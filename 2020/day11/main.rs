//use std::collections::HashMap;
use std::env;
use std::fmt;
use std::fs;
use std::io::{self, BufRead};
use std::iter::FromIterator;

#[derive(Debug)]
struct Seating {
    seats: Vec<Vec<char>>,
}

impl fmt::Display for Seating {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let s = self
            .seats
            .iter()
            .map(String::from_iter)
            .collect::<Vec<String>>()
            .join("\n");
        write!(f, "{}", s)
    }
}

impl Seating {
    fn point(&self, i: i32, j: i32) -> Option<char> {
        if i < 0
            || j < 0
            || j as usize >= self.seats.len()
            || i as usize >= self.seats[j as usize].len()
        {
            return None;
        }
        Some(self.seats[j as usize][i as usize])
    }

    fn visible_seats(&self, i: usize, j: usize, part2: bool) -> usize {
        let mut count: usize = 0;
        for ii in -1..2 {
            for jj in -1..2 {
                if ii == 0 && jj == 0 {
                    continue;
                }
                //println!("{} {} {} {}", i, j, ii, jj);
                let (mut x, mut y) = (i as i32, j as i32);
                let mut ok = true;
                while ok {
                    x += ii;
                    y += jj;
                    ok = match self.point(x, y) {
                        Some('#') => {
                            count += 1;
                            false
                        }
                        Some('L') => false,
                        Some(_) => part2,
                        None => false,
                    }
                }
            }
        }
        count
    }

    // Rules:
    // - If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
    // - If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
    // - Otherwise, the seat's state does not change.
    fn run(&mut self, part2: bool) -> bool {
        let mut updated = false;
        let mut grid = Vec::new();
        for j in 0..self.seats.len() {
            let mut row = Vec::new();
            for i in 0..self.seats[j].len() {
                let occupied_seats = self.visible_seats(i, j, part2);

                row.push(match self.seats[j][i] {
                    'L' => {
                        if occupied_seats == 0 {
                            updated = true;
                            '#'
                        } else {
                            'L'
                        }
                    }
                    '#' => {
                        if !part2 && occupied_seats >= 4 || part2 && occupied_seats >= 5 {
                            updated = true;
                            'L'
                        } else {
                            '#'
                        }
                    }
                    x => x,
                })
            }
            grid.push(row);
        }
        self.seats = grid;
        updated
    }
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut seats = Vec::new();

    for line in lines {
        let s = line?;

        seats.push(s.chars().collect());
    }
    let mut seating = Seating { seats: seats };

    let mut count = 0;
    while seating.run(true) {
        count += 1;
    }
    println!("ran {}", count);

    let occupied_seats: usize = seating
        .seats
        .iter()
        .map(|row| row.iter().filter(|c| *c == &'#').count())
        .sum();
    println!("{} occupied seats", occupied_seats);
    println!("{}", seating.to_string());
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part1() {
        let mut seating = Seating {
            seats: "L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL"
                .split_whitespace()
                .map(|l| l.chars().collect())
                .collect(),
        };
        println!("HERE {:?}", seating);
        assert!(seating.run(false));
        assert_eq!(
            seating.to_string(),
            "#.##.##.##
#######.##
#.#.#..#..
####.##.##
#.##.##.##
#.#####.##
..#.#.....
##########
#.######.#
#.#####.##"
        );
    }
}
