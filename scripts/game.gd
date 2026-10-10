extends Control

# Prototype 0.1: ระบบหลักก่อนใส่ภาพวาดจริง
# ฉากสีน้ำและภาพแมวจริงจะถูกแยกเป็น asset เพื่อเปลี่ยนเฟอร์นิเจอร์ได้ภายหลัง

const CATS := [
    {"name": "มะลิ", "pattern": "แมวลายสลิด", "emoji": "🐈", "personality": "ขี้อ้อน", "hunger": 78, "happiness": 72},
    {"name": "ข้าวปั้น", "pattern": "แมวขาวส้ม", "emoji": "🐈", "personality": "ขี้อาย", "hunger": 78, "happiness": 65},
    {"name": "ส้มจี๊ด", "pattern": "แมวส้ม", "emoji": "🐈", "personality": "กวน ๆ ซุกซน ชอบแกล้ง", "hunger": 78, "happiness": 80}
]

var cat_data: Dictionary = {}
var cat_age: String = "ลูกแมว"
var baht := 500
var meow_points := 0
var gems := 10
var action_count := 0
var status_labels := {}
var bars := {}
var cat_face: Label
var message_label: Label
var room_label: Label
var furniture := {"เตียง": "เตียงมาตรฐาน", "พรม": "พรมมาตรฐาน"}

var bg: ColorRect
var root_box: VBoxContainer

func _ready() -> void:
    randomize()
    _build_ui()
    _choose_first_cat()
    _update_ui()
    _show_message("วันฝนพรำวันหนึ่ง คุณพบลูกแมวเปียกฝนอยู่ข้างทาง…")

func _build_ui() -> void:
    bg = ColorRect.new()
    bg.color = Color("#f5e8d5")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    scroll.offset_left = 18
    scroll.offset_top = 18
    scroll.offset_right = -18
    scroll.offset_bottom = -18
    add_child(scroll)

    root_box = VBoxContainer.new()
    root_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root_box.add_theme_constant_override("separation", 12)
    scroll.add_child(root_box)

    var title := Label.new()
    title.text = "🐾  แมวตัวน้อยในวันที่ฝนพรำ"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", Color("#725647"))
    root_box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "ต้นแบบเกมเลี้ยงแมวฮีลใจ • Prototype 0.1"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_color_override("font_color", Color("#987c68"))
    root_box.add_child(subtitle)

    var room_panel := _panel()
    root_box.add_child(room_panel)
    var room_box := VBoxContainer.new()
    room_box.add_theme_constant_override("separation", 7)
    room_panel.add_child(room_box)

    room_label = Label.new()
    room_label.text = "ห้องพักของคุณ"
    room_label.add_theme_font_size_override("font_size", 20)
    room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    room_box.add_child(room_label)

    var room_scene := Label.new()
    room_scene.name = "RoomPlaceholder"
    room_scene.text = "☀️  หน้าต่าง  •  ต้นไม้  •  ชั้นหนังสือ\n\n          🪴     🐈     🛏️\n\nฉากสีน้ำและตัวแมวแอนิเมชันจะมาในขั้นถัดไป"
    room_scene.custom_minimum_size = Vector2(0, 175)
    room_scene.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    room_scene.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    room_scene.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    room_scene.add_theme_font_size_override("font_size", 19)
    room_scene.add_theme_color_override("font_color", Color("#725647"))
    room_box.add_child(room_scene)

    cat_face = Label.new()
    cat_face.text = "🐈"
    cat_face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    cat_face.add_theme_font_size_override("font_size", 60)
    room_box.add_child(cat_face)

    message_label = Label.new()
    message_label.text = ""
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    message_label.add_theme_color_override("font_color", Color("#8c6556"))
    room_box.add_child(message_label)

    var status_panel := _panel()
    root_box.add_child(status_panel)
    var status_box := VBoxContainer.new()
    status_box.add_theme_constant_override("separation", 7)
    status_panel.add_child(status_box)
    var status_title := Label.new()
    status_title.text = "สถานะของเจ้าเหมียว"
    status_title.add_theme_font_size_override("font_size", 19)
    status_box.add_child(status_title)

    _add_stat(status_box, "ความหิว", "hunger", Color("#e7a65d"))
    _add_stat(status_box, "ความสุข", "happiness", Color("#df8ca1"))
    _add_stat(status_box, "ความสะอาด", "cleanliness", Color("#83b5a1"))

    var action_panel := _panel()
    root_box.add_child(action_panel)
    var action_box := VBoxContainer.new()
    action_box.add_theme_constant_override("separation", 8)
    action_panel.add_child(action_box)
    var action_title := Label.new()
    action_title.text = "ดูแลและใช้เวลากับแมว"
    action_title.add_theme_font_size_override("font_size", 19)
    action_box.add_child(action_title)

    _add_button_row(action_box, [
        ["ลูบหัว", Callable(self, "_on_pet_head")],
        ["เกาคาง", Callable(self, "_on_scratch_chin")],
        ["เกาพุง", Callable(self, "_on_scratch_belly")]
    ])
    _add_button_row(action_box, [
        ["กอดแมว", Callable(self, "_on_hug")],
        ["ให้อาหาร", Callable(self, "_on_feed")],
        ["ทำความสะอาด", Callable(self, "_on_clean")]
    ])
    _add_button_row(action_box, [
        ["พาไปเดินเล่น", Callable(self, "_on_walk")],
        ["ตกแต่งห้อง", Callable(self, "_on_decorate")],
        ["ร้าน Pet Shop", Callable(self, "_on_shop")]
    ])

    var economy_panel := _panel()
    root_box.add_child(economy_panel)
    var economy := Label.new()
    economy.name = "EconomyLabel"
    economy.text = ""
    economy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    economy.add_theme_font_size_override("font_size", 17)
    economy.add_theme_color_override("font_color", Color("#725647"))
    economy_panel.add_child(economy)

    var age_panel := _panel()
    root_box.add_child(age_panel)
    var age_box := VBoxContainer.new()
    age_box.add_theme_constant_override("separation", 6)
    age_panel.add_child(age_box)
    var age_title := Label.new()
    age_title.text = "ช่วงวัยของแมว (ตัวอย่างระบบ)"
    age_title.add_theme_font_size_override("font_size", 18)
    age_box.add_child(age_title)
    _add_button_row(age_box, [
        ["ลูกแมว", Callable(self, "_set_kitten")],
        ["แมวโต", Callable(self, "_set_adult")],
        ["แมวแก่", Callable(self, "_set_senior")]
    ])

    var note := Label.new()
    note.text = "หมายเหตุ: เวอร์ชันนี้เป็นต้นแบบระบบ ใช้สัญลักษณ์แทนภาพชั่วคราว ยังไม่มีภาพสีน้ำหรือแอนิเมชันภาพจริง"
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.add_theme_font_size_override("font_size", 13)
    note.add_theme_color_override("font_color", Color("#987c68"))
    root_box.add_child(note)

    var timer := Timer.new()
    timer.wait_time = 30.0
    timer.timeout.connect(_on_game_tick)
    add_child(timer)
    timer.start()

func _panel() -> PanelContainer:
    var panel := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#fff9ef")
    style.border_color = Color("#e5d1b9")
    style.set_border_width_all(1)
    style.set_corner_radius_all(14)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _add_stat(parent: VBoxContainer, label_text: String, key: String, fill: Color) -> void:
    var row := HBoxContainer.new()
    parent.add_child(row)
    var label := Label.new()
    label.text = label_text
    label.custom_minimum_size.x = 100
    row.add_child(label)
    var bar := ProgressBar.new()
    bar.min_value = 0
    bar.max_value = 100
    bar.value = 70
    bar.show_percentage = true
    bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.custom_minimum_size.y = 22
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.set_corner_radius_all(8)
    bar.add_theme_stylebox_override("fill", style)
    row.add_child(bar)
    bars[key] = bar

func _add_button_row(parent: VBoxContainer, entries: Array) -> void:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 6)
    parent.add_child(row)
    for entry in entries:
        var button := Button.new()
        button.text = entry[0]
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.custom_minimum_size.y = 44
        button.add_theme_font_size_override("font_size", 15)
        button.pressed.connect(entry[1])
        row.add_child(button)

func _choose_first_cat() -> void:
    cat_data = CATS[randi_range(0, CATS.size() - 1)].duplicate(true)
    cat_data["cleanliness"] = 80
    cat_data["age_days"] = 0
    cat_data["age"] = "ลูกแมว"
    cat_age = "ลูกแมว"
    _show_message("คุณอุ้ม " + cat_data.name + " กลับบ้านจากฝนที่ตกหนัก")

func _update_ui() -> void:
    if cat_data.is_empty():
        return
    for key in ["hunger", "happiness", "cleanliness"]:
        bars[key].value = cat_data.get(key, 50)
    var economy_label = get_node_or_null("ScrollContainer/VBoxContainer/PanelContainer2/EconomyLabel")
    # อัปเดตข้อความเงินด้วยการค้นหาชื่อ เพื่อไม่ผูกกับลำดับ panel
    var labels := find_children("EconomyLabel", "Label", true, false)
    if labels.size() > 0:
        labels[0].text = "💵 บาทในเกม: %d     🐾 Meow: %d     💎 เพชร: %d\nแมว: %s • %s • ช่วงวัย: %s\nเฟอร์นิเจอร์: %s / %s" % [
            baht, meow_points, gems, cat_data.name, cat_data.personality, cat_age,
            furniture["เตียง"], furniture["พรม"]
        ]
    if cat_data.get("personality", "") == "กวน ๆ ซุกซน ชอบแกล้ง":
        cat_face.text = "😼"
    else:
        cat_face.text = "🐈"

func _show_message(text: String) -> void:
    if message_label:
        message_label.text = text

func _animate_cat(message: String, happiness_gain: int = 3) -> void:
    cat_data["happiness"] = clampi(int(cat_data.get("happiness", 50)) + happiness_gain, 0, 100)
    action_count += 1
    _show_message(message)
    var tween := create_tween()
    tween.tween_property(cat_face, "scale", Vector2(1.16, 0.88), 0.12)
    tween.tween_property(cat_face, "scale", Vector2(0.92, 1.12), 0.12)
    tween.tween_property(cat_face, "scale", Vector2.ONE, 0.12)
    _update_ui()
    if action_count % 3 == 0:
        meow_points += 1
        _show_message(message + "  ได้รับ Meow +1")
        _update_ui()

func _on_pet_head() -> void:
    _animate_cat(cat_data.name + " หลับตาพริ้มเมื่อคุณลูบหัว", 4)

func _on_scratch_chin() -> void:
    _animate_cat(cat_data.name + " เชิดคางให้เกาอย่างพอใจ", 5)

func _on_scratch_belly() -> void:
    if cat_data.personality == "กวน ๆ ซุกซน ชอบแกล้ง" and randi_range(0, 1) == 0:
        _animate_cat("ส้มจี๊ดคว้ามือคุณเบา ๆ แล้วกลิ้งหนีไปอย่างกวน ๆ", 2)
    else:
        _animate_cat(cat_data.name + " กลิ้งตัวรับการเกาพุง", 4)

func _on_hug() -> void:
    _animate_cat("คุณกอด " + cat_data.name + " อย่างอ่อนโยน", 6)

func _on_feed() -> void:
    if baht < 10:
        _show_message("เงินไม่พอซื้ออาหาร ลองไปทำงานในเวอร์ชันถัดไป")
        return
    baht -= 10
    cat_data["hunger"] = clampi(int(cat_data.hunger) + 22, 0, 100)
    _animate_cat(cat_data.name + " กินอาหารจนเริ่มอิ่ม", 2)
    _update_ui()

func _on_clean() -> void:
    cat_data["cleanliness"] = clampi(int(cat_data.cleanliness) + 25, 0, 100)
    _show_message("ห้องสะอาดแล้ว และกระบะทรายก็เรียบร้อย")
    _update_ui()

func _on_walk() -> void:
    cat_data["happiness"] = clampi(int(cat_data.happiness) + 12, 0, 100)
    meow_points += 1
    _show_message("คุณพา " + cat_data.name + " เดินเล่น วันนี้ได้ออกไปสูดอากาศด้วยกัน • ความสุข +12")
    _update_ui()

func _on_decorate() -> void:
    if baht >= 100:
        baht -= 100
        furniture["เตียง"] = "เตียงลายดอกไม้"
        _show_message("ซื้อเตียงลายดอกไม้แล้ว (ตัวอย่างระบบตกแต่ง)")
    else:
        _show_message("ต้องมีเงิน 100 บาทในเกมเพื่อซื้อเตียงใหม่")
    _update_ui()

func _on_shop() -> void:
    _show_message("Pet Shop: อาหาร 10 บาท • เตียง 100 บาท • แมวใหม่และไอเทมพิเศษจะเพิ่มภายหลัง")
    if baht >= 10:
        baht -= 10
        _show_message("ซื้ออาหารแมว 1 หน่วยแล้ว")
    _update_ui()

func _set_kitten() -> void:
    cat_age = "ลูกแมว"
    cat_data["age"] = cat_age
    _show_message("ลูกแมวต้องการการดูแลบ่อย และชอบเล่น")
    _update_ui()

func _set_adult() -> void:
    cat_age = "แมวโต"
    cat_data["age"] = cat_age
    _show_message("แมวโตมีพลังงานมากขึ้น และเริ่มมีนิสัยชัดเจน")
    _update_ui()

func _set_senior() -> void:
    cat_age = "แมวแก่"
    cat_data["age"] = cat_age
    _show_message("แมวแก่ชอบพักผ่อน ต้องการกิจกรรมเบา ๆ และการดูแลใกล้ชิด")
    _update_ui()

func _on_game_tick() -> void:
    if cat_data.is_empty():
        return
    cat_data["hunger"] = maxi(0, int(cat_data.hunger) - 2)
    cat_data["happiness"] = maxi(0, int(cat_data.happiness) - 1)
    cat_data["cleanliness"] = maxi(0, int(cat_data.cleanliness) - 1)
    cat_data["age_days"] = int(cat_data.get("age_days", 0)) + 1
    _update_ui()
