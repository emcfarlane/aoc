use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let mut lines = io::BufReader::new(file).lines();

    let time: usize = lines.next().unwrap()?.parse().unwrap();
    let list = lines.next().unwrap()?;

    //let bus_ids: Vec<usize> = list
    //    .split(',')
    //    .filter(|x| x != &"x")
    //    .map(|s| s.parse::<usize>().unwrap())
    //    .collect();
    let mut bus_ids = Vec::new();
    let mut bus_idx = HashMap::new();
    for (idx, id) in list.split(',').enumerate() {
        if id == "x" {
            continue;
        }
        let bus_id = id.parse::<usize>().unwrap();
        bus_ids.push(bus_id);
        bus_idx.insert(bus_id, idx);
    }

    let mut earliest: Option<(usize, usize)> = None;
    for bus_id in bus_ids.iter() {
        let r = time % bus_id;
        let wait = bus_id - r;
        match earliest {
            Some(e) => {
                if wait < e.1 {
                    earliest = Some((*bus_id, wait));
                }
            }
            None => earliest = Some((*bus_id, wait)),
        }
        println!("wait {} {}", bus_id, wait);
    }

    println!("{:?}", bus_ids);
    let e = earliest.unwrap();
    println!("earliest {:?} {}", e, e.0 * e.1);

    let mut mul = 1;
    let mut t = 0;
    for bus_id in bus_ids.iter() {
        let idx = bus_idx[&bus_id];
        println!("bus_id {}, idx {}, mul {}, t {}", bus_id, idx, mul, t);

        loop {
            let target = t + idx;
            let found = target > 0 && target % bus_id == 0;
            if found {
                break;
            }
            t += mul;
        }
        mul = mul * bus_id;
    }
    println!("t {}", t);
    Ok(())
}
