# Git Flow 实战报告

## 1. Git Flow 各分支职责

| 分支 | 职责 | 生命周期 | 创建来源 | 合并目标 |
|---|---|---|---|---|
| **main** (master) | 生产就绪代码，每个提交对应一个可发布的版本 | 永久 | — | — |
| **develop** | 日常开发集成分支，包含最新已完成的 feature | 永久 | main | main (via release) |
| **feature/*** | 具体功能开发，完成后删除 | 临时 | develop | develop |
| **release/*** | 发布前准备（版本号、小 bug 修复），完成后删除 | 临时 | develop | main + develop |
| **hotfix/*** | 线上紧急 bug 修复，完成后删除 | 临时 | main (tag) | main + develop |

### 核心原则

- **main 永远可部署**：只接受 release 和 hotfix 的合并
- **feature 从 develop 分出**，完成后必须合并回 develop
- **release 从 develop 分出**，合并到 main 发布后也要合并回 develop
- **hotfix 从 main 的 tag 分出**，修复后同时合并到 main 和 develop

---

## 2. 项目改造：简易用户管理系统

### 新增文件

| 文件 | 职责 | 关键 API |
|---|---|---|
| `UserModel.h/.m` | 用户数据模型 | `userId`, `name`, `role` 属性；`description` 方法 |
| `UserManager.h/.m` | 用户管理器（单例） | `addUser:`、`removeUserById:`、`findUserById:`、`listUsers`、`userCount` |
| `ViewController.m` (改造) | 验证入口 | 初始化添加 3 个用户，验证增删查功能 |

### 代码结构

```
SwiftOC/
├── UserModel.h / .m       # 用户模型
├── UserManager.h / .m     # 用户管理器 (单例，NSMutableArray 存储)
├── ViewController.m       # 验证逻辑 + UI 展示
├── SwiftClass.swift        # Swift 类 (跨语言互调)
├── OCClass.h / .m         # OC 类
└── ...
```

### 关键方法（冲突焦点）

```objc
// v1.0.0 (原始版本 — 有 bug)
- (void)removeUserById:(NSInteger)userId {
    [self.users removeObjectAtIndex:userId];  // ← userId 作为 index 使用，越界即 crash
}
```

---

## 3. 线上紧急 Bug 修复流程

### 3.1 Bug 发现与响应

**线上 Crash 报告**：

```
Fatal Exception: NSRangeException
-[__NSArrayM removeObjectAtIndex:]: index 99 beyond bounds [0 .. 2]
```

**定位**：`UserManager.removeUserById:` 第 34 行，将 `userId` 直接当作数组下标使用，当传入不存在的 userId 时产生越界。

### 3.2 修复流程（命令序列）

```bash
# 1. 从 main 的 v1.0.0 tag 拉出 hotfix 分支
git checkout -b hotfix/1.0.1 v1.0.0
git push -u origin hotfix/1.0.1

# 2. 修改 UserManager.m 的 removeUserById: 方法
#    (见下方修复代码)

# 3. 提交 hotfix
git add -A && git commit -m "hotfix: add bounds check in removeUserById to prevent crash"
git push origin hotfix/1.0.1

# 4. 合并到 main，打 tag 发布
git checkout main
git merge hotfix/1.0.1 --no-ff -m "hotfix: release v1.0.1"
git tag v1.0.1
git push origin main --tags

# 5. 合并回 develop（⚠️ 这里触发了冲突，见第4节）
git checkout develop
git merge hotfix/1.0.1 --no-ff   # → CONFLICT!
```

### 3.3 Hotfix 修复代码

```objc
- (void)removeUserById:(NSInteger)userId {
    // hotfix/1.0.1: add bounds check to prevent crash
    for (NSInteger i = 0; i < self.users.count; i++) {
        if (self.users[i].userId == userId) {
            [self.users removeObjectAtIndex:i];
            return;
        }
    }
    NSLog(@"Warning: user %ld not found, skipping removal", (long)userId);
}
```

---

## 4. 冲突发现、排查与解决全过程

### 4.1 冲突发现

执行 `git merge hotfix/1.0.1` 时输出：

```
Auto-merging SwiftOC/UserManager.m
CONFLICT (content): Merge conflict in SwiftOC/UserManager.m
Automatic merge failed; fix conflicts and then commit the result.
```

### 4.2 冲突排查

**Step 1: 查看状态**

```bash
$ git status
On branch develop
You have unmerged paths.
  both modified:   SwiftOC/UserManager.m
```

**Step 2: 查看冲突内容**

```bash
$ git diff
```

冲突标记如下：

```objc
<<<<<<< HEAD
    // feature/add-validation: use indexOfObjectPassingTest for safer lookup
    NSInteger index = [self.users indexOfObjectPassingTest:^BOOL(UserModel *obj, ...) {
        ...
    }];
    if (index != NSNotFound) {
        [self.users removeObjectAtIndex:index];
    }
=======
    // hotfix/1.0.1: add bounds check to prevent crash
    for (NSInteger i = 0; i < self.users.count; i++) {
        ...
    }
    NSLog(@"Warning: user %ld not found, skipping removal", (long)userId);
>>>>>>> hotfix/1.0.1
```

**Step 3: 分析双方改动意图**

| 来源 | 改动方式 | 优点 | 缺点 |
|---|---|---|---|
| **HEAD** (feature/add-validation) | `indexOfObjectPassingTest:` + `NSNotFound` 判断 | API 语义清晰，声明式风格 | 缺少未找到时的日志 |
| **hotfix/1.0.1** | for 循环遍历 + 未找到时 `NSLog` | 有明确的未找到提示 | 命令式风格，代码稍啰嗦 |

**根本原因**：两个分支都对 `removeUserById:` 做了修改，但采用了完全不同的实现方式，Git 无法自动判定取舍。

### 4.3 冲突解决

**决策**：保留 `indexOfObjectPassingTest:` 的查找逻辑（更现代化、声明式），同时吸收 hotfix 的 warning 日志（提升可调试性）。

**解决后的代码**：

```objc
- (void)removeUserById:(NSInteger)userId {
    // Resolved: combine feature's indexOfObjectPassingTest + hotfix's warning log
    NSInteger index = [self.users indexOfObjectPassingTest:^BOOL(UserModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.userId == userId) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound) {
        [self.users removeObjectAtIndex:index];
    } else {
        NSLog(@"Warning: user %ld not found, skipping removal", (long)userId);
    }
}
```

**提交解决**：

```bash
git add -A
git commit -m "merge: resolve conflict in removeUserById - combine indexOfObjectPassingTest with warning log"
git push origin develop
```

---

## 5. 最终分支状态图

```
*   [develop] merge: resolve conflict in removeUserById
|\
| * [hotfix/1.0.1] hotfix: add bounds check in removeUserById
| * [main] hotfix: release v1.0.1 - fix removeUserById crash (tag: v1.0.1)
* | [feature/add-validation] feat: use indexOfObjectPassingTest for safe removal
* | [develop] feat: merge add-validation into develop
|/
* [release/1.0.0] chore: release v1.0.0 (tag: v1.0.0)
* [develop] feat: merge UserManager feature into develop
* [feature/user-management] feat: integrate UserManager into ViewController
* [feature/user-management] feat: add UserManager - singleton with CRUD operations
* [feature/user-management] feat: add UserModel - user data model
* [main] feat: initial project setup
```

| Tag | 分支 | 状态 | 关键内容 |
|---|---|---|---|
| `v1.0.0` | main | 初始发布 | 含 crash bug (`removeObjectAtIndex` 无边界检查) |
| `v1.0.1` | main | ✅ 紧急修复 | 加 for-loop 边界检查 + warning 日志 |
| — | develop | ✅ 已解决冲突 | 合并了 feature 的 `indexOfObjectPassingTest` + hotfix 的 warning |

---

## 6. 总结

### Git Flow 关键要点

1. **main 是"金库"**：不要直接提交，只通过 release/hotfix 合并
2. **hotfix 是"消防通道"**：从 main 的 tag 拉出，修复后双向合并（main + develop）
3. **冲突常在合并 hotfix 到 develop 时发生**：因为 develop 可能有并行 feature 修改了同一处代码
4. **冲突解决的黄金法则**：理解双方意图，取长补短，而非简单二选一

### 本次实战的核心教训

- `removeUserById:` 的 bug 是典型的"类型误用"：把 userId（逻辑 ID）当作数组下标使用
- hotfix 和 feature 同时修复了同一方法 → 不可避免的冲突
- 解决时要**理解代码逻辑，而非机械删冲突标记**
