class LocationService
    def self.get_image(id : Int32) : Hash(String, String) | Bool | Nil
        begin
            name = RickAndMortyApi.get_location_name(id)
        rescue ex : Exception
            # If the location could not be found, return false
            return false
        end
        
        # Removes all text between parentheses, replaces spaces with underscores and removes apostrophes
        name = name.gsub(/ \([^)]*\)/, "").gsub(" ", "_").gsub("'", "")

        # Gets the image from the Rick and Morty Wiki
        response = HTTP::Client.get("https://rickandmorty.fandom.com/wiki/#{name}")
        
        if response.status_code == 301 || response.status_code == 302 || response.status_code == 308
            response = HTTP::Client.get(response.headers["location"])
        end

        if response.status_code != 200
            # If the request was not successful, return nil
            return nil
        end

        # Parses the response to a document
        document = Lexbor::Parser.new(response.body)

        begin
            # Gets the image url and removes the /revision/... part of url
            #url = document.css(%q{figure[class="pi-item pi-image"] > a[class="image image-thumbnail"]}).map(&.attribute_by("href")).to_a.first.not_nil!.sub(/\/revision\/.*$/, "")
            url = document.css(%q{figure[class="pi-item pi-image"] > a[class="image image-thumbnail"]}).map(&.attribute_by("href")).to_a.first.not_nil!.sub(/\?cb.*$/, "")
        rescue
            # If the image could not be found, return an error
            puts "Error: [RickAndMorty Wiki] Could not find image"
            return raise "Error: [RickAndMorty Wiki] Could not find image"
        end

        return {"url" => url}
    end
end