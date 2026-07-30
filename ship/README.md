# ship/

Модуль корабля. Визуал сконвертирован из Unity-ассета *Stylized Pirate Ship*
(Built-in RP) под Godot 4.5. Ассет пришёл одним FBX с шестью материалами и
набором props (бочка, ящик, пушка, паллета), которые в оригинале «летали»
рядом с корпусом.

## Структура

```
ship/
├── StylShip_Unity.fbx        # исходная модель (Import Script НЕ назначен)
├── ship.tscn                 # Ship (Node3D) → Boat (RigidBody3D) → ShipHull + коллайдер + 4 зонда
├── ship.gd                   # рантайм: probe-based плавучесть (apply_force по глубине зонда)
├── ship_hull.tscn            # визуальный корпус БЕЗ props — генерируется ship_build.gd, не редактировать вручную
│
├── textures/                 # PBR-карты (albedo/normal/roughness/metallic/ao)
├── materials/                # 6 × Mat_StylShip_*.tres — генерируются ship_material_setup.gd
├── meshes/                   # геометрия props только (.res, без материала) — генерируются ship_build.gd
│
├── cannon/  barrel/  box/  pallet/   # слайсы props (физика + коллизия + логика, собираются вручную)
│
└── tools/                    # билд-пайплайн; в рантайме не участвует
    ├── ship_build.gd         # одним проходом: экспортирует props → meshes/*.res и сохраняет корпус → ship_hull.tscn
    ├── ship_material_setup.gd  # генерирует 6 StandardMaterial3D из PBR-текстур и сохраняет в materials/*.tres
    └── ship_bind_materials.gd  # прописывает .tres в .fbx.import как «Use External» — запускать после setup
```

## Два принципа раскладки

**Сырьё против слайсов.** `fbx`, `textures/`, `materials/`, `meshes/` и
`ship_hull.tscn` — производное: пересобирается из FBX скриптами, руками не
редактируется. Слайсы props (`cannon/` и т.д.) — рукотворное: физика,
коллизии, логика. Слайс ссылается на `meshes/*.res`, но не владеет им.
Художник переэкспортировал FBX → пересобрал сырьё → слайсы подхватили новую
геометрию по ссылке, а физика осталась цела.

**Рантайм против инструментов.** Всё в корне `ship/` — часть игрового объекта.
Всё в `tools/` — билд-пайплайн: запускается вручную по необходимости и в игре
не участвует.

## Пайплайн: как пересобрать из FBX

Порядок важен — вырезание props и экспорт мешей конфликтуют, поэтому объединены
в один проход `ship_build.gd`, читающий сырой FBX.

1. У FBX в Import Script оставить **пусто** (props должны присутствовать в модели).
2. Запустить `tools/ship_build.gd` (File → Run). За один проход он:
   - экспортирует геометрию каждого prop в `meshes/*.res`;
   - сохраняет корабль без props в `ship_hull.tscn`.
3. `ship.tscn` инстансирует `ship_hull.tscn` как визуальный слой.

`ship_material_setup.gd` и `ship_bind_materials.gd` уже отработали (материалы в
`materials/`, привязка вшита в `.fbx.import`); нужны только при смене текстур
или переносе проекта — тогда запускать в этом порядке: setup → bind.

## Как добавить слайс prop

`meshes/*.res` содержат **только геометрию, без материала** (так обойдён баг
с UID при сохранении surface-материала в отдельный `.res`).

1. Новая сцена в `ship/<prop>/`, например `cannon/cannon.tscn`.
2. Корень — `RigidBody3D` (подвижный груз) или `StaticBody3D` (закреплённый).
3. Внутрь: `MeshInstance3D` (Mesh → `res://ship/meshes/cannon.res`) и
   `CollisionShape3D` (Box/Cylinder под форму).
4. У `MeshInstance3D` в слот **Material Override** — `Mat_StylShip_Props.tres`.
5. Логику — в `cannon/cannon.gd`.

## Заметки

- **Текстуры импорта.** Все карты — VRAM Compressed; нормали с флагом Normal Map;
  roughness-режим Disabled (готовые инвертированные карты, а не вывод из нормали).
- **Позиции зондов и размер коллайдера** в `ship.tscn` — заглушки (нули). Расставить
  Probe1–4 по углам ватерлинии и подогнать BoxShape3D под объём корпуса вручную в редакторе.
