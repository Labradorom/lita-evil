module Lita
  module Handlers
    class Evil < Handler
      URL = "https://ajax.googleapis.com/ajax/services/search/images"

      route(/dolphin/) do |response|
        http_response = http.get(
          URL,
          v: "1.0",
          q: "Tom+Brady",
          safe: :moderate,
          rsz: 8
        )

        data = MultiJson.load(http_response.body)

        if data["responseStatus"] == 200
          choice = data["responseData"]["results"].sample
          if choice
            response.reply ensure_extension(choice["unescapedUrl"])
          else
            response.reply %{No images found for "#{query}".}
          end
        else
          reason = data["responseDetails"] || "unknown error"
          Lita.logger.warn(
            "Couldn't get image from Google: #{reason}"
          )
        end

      end

      def log_if_debug(message)
        if config.debug
          Lita.logger.info message
        end
      end

      def ensure_extension(url)
        if [".gif", ".jpg", ".jpeg", ".png"].any? { |ext| url.end_with?(ext) }
          url
        else
          "#{url}#.png"
        end
      end

      Lita.register_handler(self)
    end
  end
end
