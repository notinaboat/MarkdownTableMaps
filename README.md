# MarkdownTableMaps.jl


### `MarkdownTableMaps.md_table_map`

    md_table_map(md, mapping) -> [a => b, ...]

Extract data from Markdown Tables in Doc Strings.

    pin_assignment_doc=
    """
    ### DAC Channel Assignments

    | DAC | Pin | Name       | Colour |
    | ---:| ---:|:---------- |:-------|
    |   1 |   0 | TEMP       | Blue   |
    |   1 |   1 | TILT       | Green  |
    |   1 |   2 | PITCH      | Purple |
    |   1 |   3 | ROLL       | Orange |
    |   2 |   0 | LIGHT      | Blue   |
    |   2 |   1 | PROX_X     | Green  |
    |   2 |   2 | PROX_X     | Purple |
    |   2 |   3 | PROX_Z     | Orange |
    """

    julia> colour_map = Dict(md_table_map(pin_assignment_doc, 3 => 4))
    Dict{String, String} with 7 entries:
      "PITCH"  => "Purple"
      "ROLL"   => "Orange"
      "LIGHT"  => "Blue"
      "PROX_X" => "Purple"
      "TEMP"   => "Blue"
      "PROX_Z" => "Orange"
      "TILT"   => "Green"

    julia> pin_map = OrderedDict(md_table_map(pin_assignment_doc,
                                 3 => row->map(x->parse(Int,x), row[1:2])))
    OrderedDict{String, Vector{Int64}} with 7 entries:
      "TEMP"   => [1, 0]
      "TILT"   => [1, 1]
      "PITCH"  => [1, 2]
      "ROLL"   => [1, 3]
      "LIGHT"  => [2, 0]
      "PROX_X" => [2, 2]
      "PROX_Z" => [2, 3]
