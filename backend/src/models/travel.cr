require "granite/adapter/pg"

class Travel < Granite::Base
  connection postgre
  table travels

  column id : Int32, primary: true
  column travel_stops : Array(Int32)
end
