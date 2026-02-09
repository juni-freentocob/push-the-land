# M1.1 测试计划（E2E + 关键子系统）

本文件用于验证 M1.1（Swamp Vertical Slice 补强）在「固定种子可复现」前提下可跑通完整一局，并保证核心交互一致：
- 手动拖拽：CardView 真移动 + CardLayer 命中分发（不使用 Godot 内置 drag/drop API）
- Board：9x9 网格、中心对齐吸附、占用表一致
- OverflowArea：容纳超出 81 格的卡，不遮挡 UI，仍可拖拽投放
- 合成：MergeRule 数据驱动、顺序无关匹配、高亮提示稳定
- Boss：100 张后进入 Boss 阶段，可被击败，胜利后 ThemeChoice 进入下一局
- 养成：XP/装备/等级（或属性增长）足以支撑击败 Boss（可控、可验证）

---

## 约定与通用前置

- 棋盘大小：board_size=9，cell_size=64（或当前实现值）
- 单局投放总数：100 张
- 可复现：DebugHUD 显示 seed/theme/spawned，并支持固定 seed（若支持输入/切换）
- UI 必须可见且不遮挡：BossPreview / ThemeChoice / DebugHUD

---

## T00 启动与复现（Baseline）

**前置条件**
- 工程可运行 Main.tscn
- DebugHUD 已显示 Seed、Theme、Spawned（或等价信息）
- 可设置固定 seed（或运行后 HUD 可读）

**操作步骤**
1. 设置固定 seed（或记录 HUD 显示 seed）
2. 运行 Main.tscn
3. 观察启动日志与 UI 布局

**预期结果**
- 无报错/无红字异常
- HUD 显示 seed/theme/spawned（spawned 初始为 0）
- Board 网格可见（GridVisual 正常）
- BossPreview 可见（占位信息可显示），ThemeChoice 默认隐藏
- 卡牌可选中且交互矩形与视觉一致（避免误选）

---

## T01 投放 100 张与 OverflowArea 行为

**前置条件**
- ThemeDef.deck_weights 已配置（可生成卡牌）
- OverflowArea 已存在并可见边界（调试底色可选）

**操作步骤**
1. 开始生成卡牌直至 spawned=100
2. 观察棋盘与 OverflowArea 的卡牌分布

**预期结果**
- Board 最多容纳 81 张（9x9），剩余卡进入 OverflowArea（应为 19 张）
- OverflowArea 卡牌排列整齐，不遮挡 BossPreview/ThemeChoice/DebugHUD
- spawned 计数准确到 100
- 生成完成后不再继续生成

---

## T02 Board 放置吸附与占用一致性

**前置条件**
- Board.accept_drop 已实现中心对齐吸附
- occupancy 表已启用（Dictionary[Vector2i, CardView] 或等价）

**操作步骤**
1. 从 OverflowArea 拖一张卡到棋盘空格
2. 再拖另一张卡到同一格
3. 拖卡到棋盘边界外（越界区域）

**预期结果**
- 第 1 张：卡牌中心对齐格子中心，放置成功，occupancy 正确登记
- 第 2 张：同格放置被拒绝（提示/日志均可），occupancy 不被污染
- 越界：放置被拒绝（提示/日志均可），卡回到原位置或保持可控状态

---

## T03 TrashZone 回收奖励与占用清理

**前置条件**
- TrashZone.accept_drop 已实现（或 CardLayer 分发到 TrashZone）
- Trash 奖励：XP +1（或当前定义）

**操作步骤**
1. 从棋盘拖一张卡到 TrashZone
2. 从 OverflowArea 拖一张卡到 TrashZone

**预期结果**
- 两种来源均可回收，卡从场景移除
- XP 增加（+1）
- 若卡来自棋盘：occupancy 对应格清理成功（无脏占用）

---

## T04 装备加成与 UI 刷新

**前置条件**
- wood_spear（EQUIPMENT）存在并可被生成/获得
- HeroPanel.accept_drop 支持装备逻辑

**操作步骤**
1. 将 wood_spear 拖到 HeroPanel
2. 观察 ATK 变化与装备卡移除

**预期结果**
- ATK 增加（例如 +1 或 atk_bonus）
- 装备卡从场景移除
- UI（HP/ATK/DEF/XP）立即刷新

---

## T05 合成规则（MergeRule）与 Hover 高亮稳定

**前置条件**
- MergeRule 可加载（顺序无关匹配）
- 规则至少包含：spirit + mud -> swamp_enemy（或当前 MVP 规则）
- CardView 有高亮层且不遮挡拖拽卡

**操作步骤**
1. 鼠标悬停在可参与合成的卡上
2. 观察可合成目标是否高亮
3. 拖拽 A 到 B 的占用格触发合成
4. 拖拽过程中移动鼠标，观察高亮是否“跳变”

**预期结果**
- 只有可合成目标被高亮
- 拖拽期间高亮来源锁定，不随鼠标跳变
- 合成成功：两张卡移除，生成 swamp_enemy，并正确注册 occupancy
- 不发生“同卡误合成”
- 拖拽卡置顶，不被高亮遮挡

---

## T06 精魂 + 地形 = 敌人（M1.1 主路径验证）

**前置条件**
- 已定义“完成态地形”（沼泽地形）判断方式
- spirit 卡可被拖到该地形格

**操作步骤**
1. 将 swamp_spirit 拖到已完成沼泽地形格
2. 观察敌人生成与占用变化

**预期结果**
- 消耗 spirit（移除或转化）
- 在目标格生成 swamp_enemy（或对应敌人）
- occupancy 更新正确（无残留引用）
- 不影响其他拖拽/高亮逻辑

---

## T07 Boss 阶段触发与 BossPreview 表现

**前置条件**
- spawned 达到 100 后会进入 BossReady/BossActive（或等价）
- BossPreview 有名称/弱点/技能字段（占位也可）

**操作步骤**
1. 让 spawned 达到 100
2. 观察 BossPreview 是否更新/提示 Boss 阶段
3. 尝试继续生成卡牌（若有生成逻辑入口）

**预期结果**
- spawned=100 时进入 Boss 阶段（HUD 或日志可证实）
- BossPreview 展示 Boss 名称/弱点/技能（占位可见且一致）
- Boss 阶段开始后不再继续生成普通卡牌

---

## T08 Boss 击败闭环（不依赖 Debug）

**前置条件**
- 存在“触发 Boss 战”的交互（ChallengeBossButton）
- Boss 有 HP（或等价状态），可被战斗系统减少直至 0

**操作步骤**
1. 点击 ChallengeBossButton 进入 BossFight（不使用 DebugBossButton）
2. 使用 DebugDamage 扣血，直至 Boss HP 归零

**预期结果**
- 点击 Challenge Boss 不应直接触发 defeated
- Boss HP 只会在 DebugDamage 时下降
- Boss 被击败后自动进入胜利流程：
  - ThemeChoice 显示并置顶（不被卡牌遮挡）
  - BossPreview 状态更新（隐藏或显示 defeated）
- 输入/拖拽在弹窗期间处于可控状态（可锁定或限定交互）

---

## T09 ThemeChoice 选择后进入下一局（最小切关）

**前置条件**
- ThemeChoice 有 3 个按钮（VBoxContainer/BoxA/BoxB/BoxC）
- 选择主题会触发切换逻辑（至少重置并开始下一轮）

**操作步骤**
1. 在 ThemeChoice 弹出后点击 BoxA/BoxB/BoxC 任意一个
2. 观察主题是否切换、局面是否重置

**预期结果**
- ThemeChoice 隐藏
- HUD theme 更新为所选主题（或输出所选 id 并立即应用）
- spawned 归零后再开始生成；Board/OverflowArea 清空
- 新一轮生成/流程可开始（可简化为重新生成 100 张；掉落进入 OverflowArea）

---

## T10 可赢保障（平衡/体验最小验证）

**前置条件**
- XP/属性增长机制已启用（击败敌人 XP > Trash XP 推荐）
- 通过装备或升级能增加 ATK/HP（任一即可）
- Boss 有固定或可预测难度（可复现）

**操作步骤**
1. 固定 seed，重复跑 3 局（或 3 次 Boss 战）
2. 每局采用“合理策略”：合成生成敌人、击败获得 XP/掉落、装备提升
3. 记录击败 Boss 时的 ATK/HP/等级（或等价指标）

**预期结果**
- 在合理策略下，3 次都能击败 Boss（无需靠运气极端抽卡）
- 击败 Boss 时的关键指标落在可接受范围（例如 ATK≈X、HP≈Y）
- 若失败：应能从 HUD seed/theme/spawned 与日志中复现并定位原因

---

## 常见失败模式与定位提示（简表）

- 放置偏移：检查是否中心对齐（card.size/2 偏移）、Board global/local 坐标换算
- 脏占用：移除卡牌时是否同步清理 occupancy；合成后新卡是否注册
- hover 遮挡：高亮层是否置于拖拽卡之下；拖拽卡是否置顶
- UI 被遮挡：ThemeChoice z_index/CanvasLayer 层级；OverflowArea 是否避开 UI 区域
- Boss 无法闭环：Boss 战触发仍依赖 Debug；Boss defeated 未自动 show ThemeChoice

---

## Step3 附加验收（Theme 切换一致性）

**前置条件**
- ThemeChoice 可选 City
- city_theme.deck_weights 指向 city_* 资源
- ThemeDef.output_remap 已配置（swamp_enemy -> city_enemy）

**操作步骤**
1. 完成一局并进入 ThemeChoice，点击 `City`
2. 观察清场、HUD 和重生
3. 在 City 局中执行 `city_spirit + city_mud` 与 `city_spirit + city_terrain_complete`
4. 将 `city_enemy` 拖到 HeroPanel

**预期结果**
- 点击 City 后旧卡全部消失（Board + OverflowArea + CardLayer）
- HUD 先显示 `0/100`（至少一帧）再回到 `100/100`
- Theme 文案切换为 City，重生卡主前缀为 `city_`
- City 合成可生成 `city_enemy`
- `city_enemy` 进入 HeroPanel 可触发战斗/掉落逻辑
