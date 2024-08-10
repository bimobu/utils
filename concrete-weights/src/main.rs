use clap::{ArgGroup, Parser, Subcommand};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Calculate the weight of a round plate
    Round {
        /// The plate outer diameter in cm
        #[arg(short, long, default_value_t = 25.0)]
        outer_diameter: f64,
        /// The mounting diameter (diameter of the hole) in cm
        #[arg(short, long, default_value_t = 3.0)]
        mounting_diameter: f64,
        /// The width of the plate in cm
        #[arg(short, long, default_value_t = 8.0)]
        width: f64,
        /// The density of the concrete in g/cm^3
        #[arg(short, long, default_value_t = 2.0)]
        density: f64,
    },
    /// Calculate the weight of a hexagonal plate
    #[clap(group(
        ArgGroup::new("radius")
            .required(true)
            .args(&["circumcircle_diameter", "incircle_diameter"]),
    ))]
    Hex {
        /// The circumcircle diameter of the hexagon
        #[arg(short, long, default_value_t = f64::NAN)]
        circumcircle_diameter: f64,
        /// The incircle diameter of the hexagon
        #[arg(short, long, default_value_t = f64::NAN)]
        incircle_diameter: f64,
        /// The mounting diameter (diameter of the hole) in cm
        #[arg(short, long, default_value_t = 3.0)]
        mounting_diameter: f64,
        /// The width of the plate in cm
        #[arg(short, long, default_value_t = 8.0)]
        width: f64,
        /// The density of the concrete in g/cm^3
        #[arg(short, long, default_value_t = 2.0)]
        density: f64,
    },
}

fn main() {
    let Args { command } = Args::parse();

    match command {
        Commands::Round {
            outer_diameter,
            mounting_diameter,
            width,
            density,
        } => print_round_plate(outer_diameter, mounting_diameter, width, density),
        Commands::Hex {
            circumcircle_diameter,
            incircle_diameter,
            mounting_diameter,
            width,
            density,
        } => print_hex_plate(
            circumcircle_diameter,
            incircle_diameter,
            mounting_diameter,
            width,
            density,
        ),
    }
}

fn print_round_plate(outer_diameter: f64, mounting_diameter: f64, width: f64, density: f64) {
    let overall_area = get_round_area(outer_diameter);
    let mounting_area = get_round_area(mounting_diameter);
    let plate_area = overall_area - mounting_area;
    let volume = plate_area * width;
    let mass = volume * density / 1000.0;
    let mass_string = format!("{:.3}", mass);

    println!("Outer Diameter: {outer_diameter}cm");
    println!("Hole Diameter: {mounting_diameter}cm");
    println!("Width: {width}cm");
    println!("Density: {density}cm");
    println!("Mass: {mass_string}kg");
}

fn print_hex_plate(
    circumcircle_diameter: f64,
    incircle_diameter: f64,
    mounting_diameter: f64,
    width: f64,
    density: f64,
) {
    let incircle_radius: f64;
    let circumcircle_radius: f64;

    if incircle_diameter.is_nan() {
        circumcircle_radius = circumcircle_diameter / 2.0;
        incircle_radius = circumcircle_radius * 3.0_f64.sqrt() / 2.0;
    } else {
        incircle_radius = incircle_diameter / 2.0;
        circumcircle_radius = incircle_radius * 2.0 / 3.0_f64.sqrt();
    }

    let overall_area = circumcircle_radius.powi(2) * 3.0 * 3.0_f64.sqrt() / 2.0;
    let mounting_area = get_round_area(mounting_diameter);
    let plate_area = overall_area - mounting_area;
    let volume = plate_area * width;
    let mass = volume * density / 1000.0;
    let mass_string = format!("{:.3}", mass);

    println!(
        "Circumcircle diameter: {}cm",
        format!("{:.1}", circumcircle_radius * 2.0)
    );
    println!(
        "Incircle diameter: {}cm",
        format!("{:.1}", incircle_radius * 2.0)
    );
    println!("Hole Diameter: {mounting_diameter}cm");
    println!("Width: {width}cm");
    println!("Density: {density}cm");
    println!("Mass: {mass_string}kg");
}

fn get_round_area(diameter: f64) -> f64 {
    let radius = diameter / 2.0;
    (radius).powi(2) * std::f64::consts::PI
}
