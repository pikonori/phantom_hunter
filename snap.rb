# -*- coding: utf-8 -*-
require 'cgi'
require 'pp'
require 'RMagick'

# スナップショットを取得する
# 木村さん専用
module Snap
  class Create
    def initialize url
      @url = url
      @save_path = "./snapshot/" + CGI::escape(@url)
      @width = 350
      @cut_px = 1000
    end

    # 画像の存在チェック
    def file_exist?
      File.exist?(@save_path + ".png")
    end

    # スナップショット作成
    def create?
      result = ""
      command_path = Dir::pwd + "/rasterize.js"
      IO.popen("phantomjs " + command_path + " '" + @url + "' " + @save_path + ".png", "r+") do |io|
        result = io.gets
      end
      # file_exist?
    end

    # カット
    def cut
      image = Magick::Image.read(@save_path + ".png").first
      loop = image.rows.quo(@cut_px).to_f.ceil
      # 画像左上を起点としてx:500, y:200の位置からwidth:300, height:100のサイズで切り取り
      # image = original.crop(500, 200, 300, 100)
      loop.times do |i|
        set_image = image.crop(0, @cut_px * i, @width, @cut_px)
        set_image.write(@save_path + "_" + i.to_s + ".png")
      end
    end

  end
end

pp ARGV[0]

snap = Snap::Create.new(ARGV[0])
# キャプチャが成功したらカットする。
snap.create?
snap.cut

