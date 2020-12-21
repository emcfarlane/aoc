use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};

static REQUIRED_FIELDS: [&str; 7] = [
    "byr", // (Birth Year)
    "iyr", // (Issue Year)
    "eyr", // (Expiration Year)
    "hgt", // (Height)
    "hcl", // (Hair Color)
    "ecl", // (Eye Color)
    "pid", // (Passport ID)
           //"cid", // (Country ID)
];

fn check(passport: &HashMap<String, String>) -> (bool, bool) {
    let mut valid = true;
    for fld in &REQUIRED_FIELDS {
        let key = &fld.to_string();
        let ok = match passport.get(key) {
            Some(val) => {
                valid &= validate(key, val);
                true
            }
            None => false,
        };
        if !ok {
            return (false, false);
        }
    }
    return (true, valid);
}

fn validate(key: &String, val: &String) -> bool {
    match key.as_str() {
        // (Birth Year) - four digits; at least 1920 and at most 2002.
        "byr" => match val.parse::<u32>() {
            Ok(x) => x >= 1920 && x <= 2002,
            Err(_) => false,
        },
        // (Issue Year) - four digits; at least 2010 and at most 2020.
        "iyr" => match val.parse::<u32>() {
            Ok(x) => x >= 2010 && x <= 2020,
            Err(_) => false,
        },
        // (Expiration Year) - four digits; at least 2020 and at most 2030.
        "eyr" => match val.parse::<u32>() {
            Ok(x) => x >= 2020 && x <= 2030,
            Err(_) => false,
        },
        // (Height) - a number followed by either cm or in:
        // If cm, the number must be at least 150 and at most 193.
        // If in, the number must be at least 59 and at most 76.
        "hgt" => {
            if val.ends_with("cm") {
                match val[..val.len() - 2].parse::<u32>() {
                    Ok(x) => x >= 150 && x <= 193,
                    Err(_) => false,
                }
            } else if val.ends_with("in") {
                match val[..val.len() - 2].parse::<u32>() {
                    Ok(x) => x >= 59 && x <= 76,
                    Err(_) => false,
                }
            } else {
                false
            }
        }
        // (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
        "hcl" => {
            let chars: Vec<char> = val.chars().collect();
            chars.len() == 7
                && chars[0] == '#'
                && chars[1..7].iter().all(|c| match c {
                    '0'..='9' => true,
                    'a'..='f' => true,
                    _ => false,
                })
        }
        // (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
        "ecl" => match val.as_str() {
            "amb" | "blu" | "brn" | "gry" | "grn" | "hzl" | "oth" => true,
            _ => false,
        },
        // (Passport ID) - a nine-digit number, including leading zeroes.
        "pid" => val.len() == 9 && val.chars().all(char::is_numeric),
        // (Country ID) - ignored, missing or not.
        "cid" => true,
        _ => false,
    }
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut passport: HashMap<String, String> = HashMap::new();
    let mut valid: i32 = 0;
    let mut invalid: i32 = 0;
    let mut validated: i32 = 0;

    for line in lines {
        let s = line?;
        // Empty line.
        if s.len() == 0 {
            let (ok, ok2) = check(&passport);
            if ok {
                valid += 1;
            } else {
                invalid += 1;
            }
            if ok2 {
                validated += 1;
            }
            passport.clear();
            continue;
        }

        let ws_split = s.split_whitespace();
        for pair in ws_split {
            let mut split = pair.split(":");
            let key = split.next().unwrap().to_string();
            let val = split.next().unwrap().to_string();
            //println!("{} {}", key, val);
            passport.insert(key, val);
        }
    }
    let (ok, ok2) = check(&passport);
    if ok {
        valid += 1;
    } else {
        invalid += 1;
    }
    if ok2 {
        validated += 1;
    }

    println!("valid passports: {}", valid);
    println!("invalid passports: {}", invalid);
    println!("validated passports: {}", validated);
    Ok(())
}
