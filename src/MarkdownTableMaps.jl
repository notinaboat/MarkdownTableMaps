"""
# MarkdownTableMaps.jl
"""
module MarkdownTableMaps

export md_table
export md_table_map
export md_table_cell
export md_table_column
export md_table_columns
export md_table_foreach_cell

using Markdown
using ReadmeDocs

function md_without_underscore_italic()
	config=deepcopy(Markdown.julia)
	filter!(!=(Markdown.underscore_italic), config.inner['_'])
	config
end


@doc README"""
    md_table_map(md, mapping) -> [a => b, ...]

Extract data from Markdown Tables in Doc Strings.

    pin_assignment_doc=
    \\"\\"\\"
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
    \\"\\"\\"

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
"""
function md_table_map(md, mapping)
    table = md_table(md)
	i, j = mapping
    if i isa AbstractString
        i = findfirst(isequal(i), md_table_columns(md))
    end
    if j isa AbstractString
        j = findfirst(isequal(j), md_table_columns(md))
    end
	if j isa Integer
		j = let _j = j
			r -> r[_j]
		end
	end
	rows = filter(row->!isempty(row[i]), table.rows[2:end])
	rows = map(row->join.(row, "\n"), rows)
	[r[i] => j(r) for r in rows]
end

function md_table(md)
	md = Markdown.parse(IOBuffer(md); flavor = md_without_underscore_italic())
	first(filter(x->x isa Markdown.Table, md.content))
end

md_table_columns(md) = md_table_columns(md_table(md))
md_table_columns(table::Markdown.Table) = join.(table.rows[1], "\n")

md_table_column(md, n) = md_table_column(md_table(md), n)
md_table_column(table::Markdown.Table, n) =
    [join(table.rows[r][n], "\n") for r in 1:length(table.rows)]

function md_table_column(md, s::String)
    n = findfirst(isequal(s), md_table_columns(md))
    md_table_column(md, n)
end

function md_table_cell(md, r::String, c::String)
    col = md_table_column(md, c)
    n = findfirst(isequal(r), md_table_column(md, 1))
    col[n]
end

function md_table_foreach_cell(f, md)
    for column_name in md_table_columns(md)[2:end]
        for (row_name, cell) in md_table_map(md, 1 => column_name)
            if cell != ""
                f(column_name, row_name, cell)
            end
        end
    end
end


end # module
