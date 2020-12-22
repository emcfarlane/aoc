use std::collections::HashSet;
use std::env;
use std::fs;
use std::io::{self, BufRead};
use std::str::FromStr;

struct Ins {
    op: String,
    value: i32,
}

impl FromStr for Ins {
    type Err = String;

    fn from_str(line: &str) -> Result<Self, Self::Err> {
        let mut words = line.split_whitespace();
        let op = words.next().unwrap().to_string();
        let value: i32 = words.next().unwrap().parse().unwrap();

        Ok(Ins { op, value })
    }
}

fn add(u: usize, i: i32) -> Option<usize> {
    if i.is_negative() {
        u.checked_sub(i.wrapping_abs() as u32 as usize)
    } else {
        u.checked_add(i as usize)
    }
}

fn run(ins_vec: &Vec<Ins>) -> (bool, i32) {
    let mut accumulator: i32 = 0;
    let mut current_line: usize = 0;
    let mut processed_lines = HashSet::new();
    loop {
        if current_line >= ins_vec.len() {
            break;
        }
        let ins = &ins_vec[current_line];
        if processed_lines.contains(&current_line) {
            println!(
                "loop detected line {}: {} {}",
                current_line, ins.op, ins.value
            );
            return (false, accumulator);
        }
        //println!("running {}: {} {}", current_line, ins.op, ins.value);

        processed_lines.insert(current_line);
        match ins.op.as_str() {
            "acc" => {
                accumulator += ins.value;
                current_line += 1;
            }
            "jmp" => match add(current_line, ins.value) {
                Some(x) => current_line = x,
                None => panic!("Current line overflow"),
            },
            "nop" => {
                current_line += 1;
            }
            &_ => (),
        }
    }
    return (true, accumulator);
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut ins_vec: Vec<Ins> = lines
        .into_iter()
        .map(|l| l.expect("Could not read line"))
        .map(|s| s.parse::<Ins>().expect("Could not parse line"))
        .collect();

    let (ok, accumulator) = run(&ins_vec);
    println!("run1 {} {}", ok, accumulator);

    //for (idx, ins) in ins_vec.iter_mut().enumerate() {
    for idx in 0..ins_vec.len() {
        {
            let ins = &mut ins_vec[idx];
            match ins.op.as_str() {
                "jmp" => ins.op = "nop".to_string(),
                "nop" => ins.op = "jmp".to_string(),
                &_ => continue,
            }
        }
        let (ok, accumulator) = run(&ins_vec);
        if ok {
            println!("invert success at {} {}", idx, accumulator);
            break;
        }
        {
            let ins = &mut ins_vec[idx];
            match ins.op.as_str() {
                "jmp" => ins.op = "nop".to_string(),
                "nop" => ins.op = "jmp".to_string(),
                &_ => panic!("what"),
            }
        }
    }

    println!("end");
    Ok(())
}
