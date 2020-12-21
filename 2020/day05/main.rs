use std::collections::HashSet;
use std::env;
use std::fs;
use std::io::{self, BufRead};
use std::str::FromStr;

struct BoardingPass {
    id: u16,
    row: u16,
    col: u16,
}

impl FromStr for BoardingPass {
    type Err = String;

    fn from_str(seat: &str) -> Result<Self, Self::Err> {
        let chars: Vec<char> = seat.chars().collect();
        if chars.len() != 10 {
            return Err("Length must be 10".to_string());
        }

        let mut id = 0;
        for (idx, ch) in chars.into_iter().rev().enumerate() {
            match ch {
                'B' | 'R' => id |= 1 << idx,
                'F' | 'L' => (),
                _ => return Err("Unknown char".to_string()),
            }
        }
        Ok(BoardingPass {
            id: id,
            row: id >> 3,
            col: id & 0b111,
        })
    }
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut max_id: u16 = 0;
    let mut ids = HashSet::new();

    for line in lines {
        let s = line?;

        let boarding_pass: BoardingPass = s.parse().unwrap();
        if boarding_pass.id > max_id {
            max_id = boarding_pass.id;
        }
        ids.insert(boarding_pass.id);
    }

    let mut missing_id: u16 = max_id;
    while ids.contains(&missing_id) {
        missing_id -= 1;
    }
    println!("max seat id {}", max_id);
    println!("missing seat id {}", missing_id);
    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;

    fn check_seat(seat: &str, expect_row: u16, expect_col: u16, expect_id: u16) {
        let boarding_pass: BoardingPass = seat.parse().unwrap();
        assert_eq!(boarding_pass.row, expect_row);
        assert_eq!(boarding_pass.col, expect_col);
        assert_eq!(boarding_pass.id, expect_id);
    }

    #[test]
    fn example_1() {
        check_seat("BFFFBBFRRR", 70, 7, 567);
    }
}
