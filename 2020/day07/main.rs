use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};
use std::str::FromStr;

#[derive(Debug)]
struct Bag {
    colour: String,
    contents: HashMap<String, usize>,
}

impl Bag {
    fn contains(
        &self,
        colour: &String,
        bags: &HashMap<String, Bag>,
        memoize: &mut HashMap<String, bool>,
    ) -> bool {
        match memoize.get(&self.colour) {
            Some(ok) => *ok,
            None => {
                let mut ok = self.contents.contains_key(colour);
                if !ok {
                    for (key, val) in self.contents.iter() {
                        ok = match bags.get(key) {
                            Some(bag) => bag.contains(colour, bags, memoize),
                            None => false,
                        };

                        if ok {
                            break;
                        }
                    }
                }

                memoize.insert(self.colour.clone(), ok);
                ok
            }
        }
    }

    fn count(&self, bags: &HashMap<String, Bag>) -> usize {
        let mut count: usize = 1;
        for (colour, n) in self.contents.iter() {
            let bag = bags.get(colour).unwrap();
            count += n * bag.count(bags);
        }
        count
    }
}

impl FromStr for Bag {
    type Err = String;

    fn from_str(rule: &str) -> Result<Self, Self::Err> {
        let mut words = rule.split_whitespace();

        let c1 = words.next().unwrap();
        let c2 = words.next().unwrap();
        words.next(); // bags
        words.next(); // contains

        let mut contents = HashMap::new();
        loop {
            let num = words.next().unwrap();
            if num == "no" {
                break;
            }
            let n: usize = num.parse().unwrap();
            let c1 = words.next().unwrap();
            let c2 = words.next().unwrap();
            contents.insert(c1.to_string() + " " + c2, n);

            let bag = words.next().unwrap();
            if bag.ends_with(".") {
                break;
            }
        }
        Ok(Bag {
            colour: c1.to_string() + " " + c2,
            contents: contents,
        })
    }
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut bags = HashMap::new();

    for line in lines {
        let s = line?;

        let bag: Bag = s.parse().unwrap();

        bags.insert(bag.colour.clone(), bag);
    }
    let goal = "shiny gold".to_string();

    let mut memoize: HashMap<String, bool> = HashMap::new();
    let mut count: usize = 0;
    for (colour, bag) in bags.iter() {
        //println!("{}: {:?}", colour, bag);
        if bag.contains(&goal, &bags, &mut memoize) {
            count += 1;
        }
    }

    let size = bags.get(&goal).unwrap().count(&bags) - 1;

    println!("bags: {}", bags.len());
    println!("{} {}", goal, count);
    println!("size {}", size);
    Ok(())
}
