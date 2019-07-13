require 'rails_helper'

RSpec.describe Scraping::V2::SeasonLineup, :vcr do
  describe '.execute' do
    let(:input_path) { './spec/fixtures/lists/scraping/v2/season_lineup/input/season_list.yml' }
    let(:old_list) { YAMLFile.open(input_path) }
    let(:new_list) { Scraping::V2::SeasonLineup.execute(old_list) }

    it 'selenium版と同じ結果を返す' do
      expect(new_list.length).to eq 2380
      expect(new_list).to eq YAMLFile.open('./spec/fixtures/lists/scraping/v2/season_lineup/output/season_list.yml')
    end

    subject(:titles_of_new_list) { new_list.map(&:title) }

    it '実行前の作品リストに登録されていなかった作品が登録される' do
      expect(titles_of_new_list).to include('荒ぶる季節の乙女どもよ。')
      expect(titles_of_new_list).to include('ありふれた職業で世界最強')
      expect(titles_of_new_list).to include('TVアニメ「あんさんぶるスターズ！」')
      expect(titles_of_new_list).to \
        include('あんさんぶるスターズ！DREAM LIVE -1st Tour “Morning Star!”- 東京追加公演ノーカット版')
      expect(titles_of_new_list).to include('異世界チート魔術師')
      expect(titles_of_new_list).to include('いぬかみっ！')
      expect(titles_of_new_list).to include('うさぎのマシュー')
      expect(titles_of_new_list).to include('炎炎ノ消防隊')
      expect(titles_of_new_list).to include('凹凸世界　シーズン2')
      expect(titles_of_new_list).to include('可愛ければ変態でも好きになってくれますか？')
      expect(titles_of_new_list).to include('牙狼＜GARO＞－VANISHING LINE－')
      expect(titles_of_new_list).to include('きみの声をとどけたい')
      expect(titles_of_new_list).to include('今日もツノがある')
      expect(titles_of_new_list).to include('グランベルム')
      expect(titles_of_new_list).to include('胡蝶綺 ～若き信長～')
      expect(titles_of_new_list).to include('戦姫絶唱シンフォギアXV')
      expect(titles_of_new_list).to include('ダンベル何キロ持てる？')
      expect(titles_of_new_list).to include('鉄人28号')
      expect(titles_of_new_list).to include('Ｄｒ．ＳＴＯＮＥ')
      expect(titles_of_new_list).to include('ナカノヒトゲノム【実況中】')
      expect(titles_of_new_list).to include('波打際のむろみさん')
      expect(titles_of_new_list).to include('魔王様、リトライ！')
      expect(titles_of_new_list).to include('RE:ステージ!ドリームデイズ♪')
    end

    it '元HTMLでエスケープされていなかった作品名を取得できている' do
      expect(titles_of_new_list).not_to include('IS')
      expect(titles_of_new_list).not_to include('IS2')
      expect(titles_of_new_list).not_to include('小さなバイキング ビッケ')
      expect(titles_of_new_list).to include('IS<インフィニット・ストラトス>')
      expect(titles_of_new_list).to include('IS<インフィニット・ストラトス>2')
      expect(titles_of_new_list).to include('小さなバイキング ビッケ<前半>')
    end

    it '作品リストにスペースがトリミングされていない作品を含まない' do
      expect(titles_of_new_list).not_to include('電脳戦隊ヴギィ’ズ・エンジェル　')
      expect(titles_of_new_list).not_to include('一人之下 羅天大ショウ篇（ラテンタイショウ篇）　')
      expect(titles_of_new_list).to include('電脳戦隊ヴギィ’ズ・エンジェル')
      expect(titles_of_new_list).to include('一人之下 羅天大ショウ篇（ラテンタイショウ篇）')
    end

    it '作品リストにニコニコ支店と本店で異なる作品名を持つ作品のニコニコ支店側の作品名が含まれない' do
      expect(titles_of_new_list).not_to \
        include('ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei  素足のGinRei Episode.1 盗まれた戦闘チャイナを捜せ大作戦！！')
      expect(titles_of_new_list).not_to \
        include('ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei  青い瞳の銀鈴 GinRei with blue eyes')
      expect(titles_of_new_list).not_to include('秘密結社 鷹の爪  THE MOVIE～総統は二度死ぬ～')
      expect(titles_of_new_list).not_to include('秘密結社 鷹の爪  THE MOVIE Ⅱ～私を愛した黒烏龍茶～')
      expect(titles_of_new_list).not_to include('秘密結社 鷹の爪  THE MOVIE Ⅲ～http://鷹の爪.jpは永遠に～')
      expect(titles_of_new_list).to \
        include('ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei 素足のGinRei Episode.1 盗まれた戦闘チャイナを捜せ大作戦！！')
      expect(titles_of_new_list).to \
        include('ジャイアント・ロボ THE ANIMATION 外伝 銀鈴 GinRei 青い瞳の銀鈴 GinRei with blue eyes')
      expect(titles_of_new_list).to include('秘密結社 鷹の爪 THE MOVIE～総統は二度死ぬ～')
      expect(titles_of_new_list).to include('秘密結社 鷹の爪 THE MOVIE Ⅱ～私を愛した黒烏龍茶～')
      expect(titles_of_new_list).to include('秘密結社 鷹の爪 THE MOVIE Ⅲ～http://鷹の爪.jpは永遠に～')
    end
  end
end
