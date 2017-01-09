require 'active_support/core_ext/object/blank'

module GtRubySdk
  class LocalServer
    TOLERANCE = 4

    class << self
      def register
        rnd1 = Digest::MD5.hexdigest(Random.rand(100).to_s)
        rnd2 = Digest::MD5.hexdigest(Random.rand(100).to_s)

        [
          rnd1,
          rnd2.to_s[0..1]
        ].join
      end

      def validate(challenge, pin_code, _seccode)
        return false if pin_code.blank?

        code_fragments = pin_code.split('_')

        ans = decode(challenge, code_fragments[0])
        bg_image_index = decode(challenge, code_fragments[1])
        image_grp_index = decode(challenge, code_fragments[2])

        validate_image(ans, bg_image_index, image_grp_index)
      end

      def validate_image(ans, bg_image_index, image_grp_index)
        full_bg_name = Digest::MD5.hexdigest(bg_image_index.to_s)[0..8]
        bg_name = Digest::MD5.hexdigest(image_grp_index.to_s)[10..18]

        array = 9.times.inject([]) do |collector, i|
          collector.push(
            i.odd? ? bg_name[i] : full_bg_name[i]
          )
        end

        x_decode = array[4..-1].join
        x_int = x_decode.to_i(16)

        result = x_int % 200
        result = result < 40 ? 40 : result

        (ans - result).abs < 4
      end

      # 解码随机参数
      def decode(challenge, code_fragment)
        return 0 if code_fragment.length > 100

        hash = {}
        duplicated_array = []
        numbers = [1, 2, 5, 10, 50]
        count = 0

        challenge.chars.each do |item|
          next if duplicated_array.include?(item)

          value = numbers[count % 5]
          duplicated_array.push(item)
          count += 1

          hash[item] = value
        end

        offset = decode_offset(challenge[32..33])
        code_fragment.chars.inject(0) { |_acc, elem| +hash[elem] } - offset
      end

      # 输入的两位的随机数字,解码出偏移量
      def decode_offset(number)
        number = number[0..1]

        array = number.codepoints.to_a.map do |codepoint|
          codepoint > 57 ? (codepoint - 87) : (codepoint - 48)
        end

        array[0] * 36 + array[1]
      end
    end
  end
end
