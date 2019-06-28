import (
  time
  os
  http
  json
)

struct Point {
	x int
	y int
}

struct HexBotColor {
	value string
}

struct HexBotResponse {
	colors []HexBotColor
}

fn print_universe(universe[]array_int, life_colour string) {
  alive := '\u25FC'
  dead := '\u25FB'
  ansi := '\x1b'
  for row in universe {
    mut rendered_row := '     '
    for col in row {
      rendered_row += if col == 1{ color_string(alive, life_colour) + ' ' } else { ansi + '[38;2;222;12;33m' + dead + ' ' + ansi + '[0m' }
    }
    println(rendered_row)
  }
  println('')
}

fn create_universe(width, height int) []array_int {
  mut universe := []array_int
  for i := 0; i < height; i++ {
      mut row := [0 ; width]
      universe << row
  }
  return universe
}

pub fn gosper_glider_gun() []Point {
  return [
   Point{24, 0},
   Point{22, 1},
   Point{24, 1},
   Point{12, 2},
   Point{13, 2},
   Point{20, 2},
   Point{21, 2},
   Point{34, 2},
   Point{35, 2},
   Point{11, 3},
   Point{15, 3},
   Point{20, 3},
   Point{21, 3},
   Point{34, 3},
   Point{35, 3},
   Point{0, 4},
   Point{1, 4},
   Point{10, 4},
   Point{16, 4},
   Point{20, 4},
   Point{21, 4},
   Point{0, 5},
   Point{1, 5},
   Point{10, 5},
   Point{14, 5},
   Point{16, 5},
   Point{17, 5},
   Point{22, 5},
   Point{24, 5},
   Point{10, 6},
   Point{16, 6},
   Point{24, 6},
   Point{11, 7},
   Point{15, 7},
   Point{12, 8},
   Point{13, 8}
  ]
}

fn add_points_to_universe(universe []array_int, points []Point, x_offset, y_offset int) []array_int {
  for point in points {
    mut x := point.x + x_offset
    mut y := point.y + y_offset
    universe[y][x] = 1
  }
  return universe
}

fn clamp(value, min, max int) int {
  if value < min {
    return min
  } else if value > max {
    return max
  }
  return value
}

fn count_live_neighbours(universe []array_int, focus_x, focus_y int) int {
  top_row := clamp(focus_y - 1, 0, universe.len - 1)
  bottom_row := clamp(focus_y + 1, 0, universe.len - 1)

  first_row := universe[0]
  left_col := clamp(focus_x - 1, 0, first_row.len - 1)
  right_col := clamp(focus_x + 1, 0, first_row.len - 1)

  mut count := 0

  for row_id := top_row; row_id <= bottom_row; row_id++ {
    for col_id := left_col; col_id <= right_col; col_id++ {
      if universe[row_id][col_id] == 1 && (focus_x != col_id || focus_y != row_id) {
        count++
      }
    }
  }

  return count
}

fn hex_char_to_decimal(hex_char string) int {
  if (hex_char == '0') { return 0 }
  if (hex_char == '1') { return 1 }
  if (hex_char == '2') { return 2 }
  if (hex_char == '3') { return 3 }
  if (hex_char == '4') { return 4 }
  if (hex_char == '5') { return 5 }
  if (hex_char == '6') { return 6 }
  if (hex_char == '7') { return 7 }
  if (hex_char == '8') { return 8 }
  if (hex_char == '9') { return 9 }
  if (hex_char == '10') { return 10 }
  if (hex_char == 'A') { return 11 }
  if (hex_char == 'B') { return 12 }
  if (hex_char == 'C') { return 13 }
  if (hex_char == 'D') { return 14 }
  if (hex_char == 'E') { return 15 }
  if (hex_char == 'F') { return 16 }
  return 0
}

fn rough_hex_to_rgb(hex string) string {
  int_val := (hex_char_to_decimal(hex.substr(0, 1)) * 16) + (hex_char_to_decimal(hex.substr(1, 2)))
  clamped := clamp(int_val, 0, 255)
  return clamped.str()
}

fn color_string(str, hex_color string) string {
  red := hex_color.substr(1, 3)
  green := hex_color.substr(3, 5)
  blue := hex_color.substr(5, 7)
  rgb := [rough_hex_to_rgb(red), rough_hex_to_rgb(green), rough_hex_to_rgb(blue)].join(';')
  return '\x1b[38;2;${rgb}m$str\x1b[0m'
}

fn main() {
  specified_width := 40
  specified_height := 40
  iterations := 1000
  mut color := '#ffffff'
  mut universe := create_universe(specified_width, specified_height)
  print_universe(universe, color)
  universe = add_points_to_universe(universe, gosper_glider_gun(), 3, 3)
  for i := 0; i < iterations; i++ {
    os.system('clear')
    mut new_universe := create_universe(specified_width, specified_height)
    for row_id, row in universe {
      for col_id, _ in row {
        live_neighbours := count_live_neighbours(universe, col_id, row_id)

        alive := bool(universe[row_id][col_id] == 1)

        if (alive && live_neighbours in [2, 3]) || (!alive && live_neighbours == 3) {
          new_universe[row_id][col_id] = 1
        } else {
          new_universe[row_id][col_id] = 0
        }
      }
    }
    universe = new_universe
    print_universe(universe, color)

    hexbot_response := json.decode(HexBotResponse, http.get('https://api.noopschallenge.com/hexbot')) or {
      eprintln('Failed to decode json')
      return
    }
    next_color := hexbot_response.colors[0].value
    println('Next color: $next_color')
    color = next_color
  }
}
