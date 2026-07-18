# WezTerm 全画面背景画像

`wezterm.lua` が全画面（native fullscreen）のときだけ、このディレクトリ内の画像を
1 枚選んで背景に敷く。**画像を追加するだけで日付ベースの日替わりが自動で有効**になる
（同じ日は同じ絵を選ぶ決定的ロジック）。

## 追加する画像の条件

- 形式: JPEG / PNG（`.jpg` / `.jpeg` / `.png`）
- 向き: 横長（ターミナル全画面に合わせて）
- 最適化: 横 ~2560px、JPEG 品質 ~60、目安 < 600KB（repo 肥大化を抑える）
  - 例: `sips --resampleWidth 2560 -s format jpeg -s formatOptions 60 in.heic --out out.jpg`
- ライセンス: 再配布可能なもの（CC0 / パブリックドメイン / Unsplash License）に限定。
  公開リポジトリにコミットされるため、下表に出典・作者・ライセンスを必ず追記すること。

## 収録画像

| ファイル | 内容 | 作者 | ライセンス | 出典 |
| --- | --- | --- | --- | --- |
| `glacier-bay-alaska.jpg` | Glacier Bay 国立公園・アラスカの氷河湾 | U.S. National Park Service | Public Domain（米国連邦政府職員の職務著作物） | <https://commons.wikimedia.org/wiki/File:Views_of_Glacier_Bay_National_Park_and_Preserve,_Alaska_(f7c85965-4042-4041-b0c5-d1d11d112c14).jpg> |
| `grand-prismatic-spring-yellowstone.jpg` | Yellowstone 国立公園・Grand Prismatic Spring の空撮 | Yellowstone National Park (NPS) | Public Domain（米国連邦政府職員の職務著作物） | <https://commons.wikimedia.org/wiki/File:Aerial_view_of_Excelsior_Geyser_and_Grand_Prismatic_Spring_(23320428202).jpg> |
| `tunnel-view-yosemite-california.jpg` | Yosemite 国立公園・Tunnel View からの渓谷（El Capitan） | EF5 (Wikimedia Commons) | CC0 1.0 | <https://commons.wikimedia.org/wiki/File:%E2%80%9CTunnel_View%E2%80%9D_overlook_showing_famous_rock_formations_in_Yosemite_Valley_04.jpg> |
