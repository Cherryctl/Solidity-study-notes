# Solidity-study-notes
📝 Solidity 教程第二课：结构体、动态数组与 msg.sender
🚀 本课目标：

  理解 struct（结构体）定义与应用

  掌握 动态数组 与 定长数组 区别

  学会使用 msg.sender 记录调用者地址

  理解 memory/storage 数据位置

  通过逐步问题解决，建立完整认知体系

📂 示例代码
solidity

    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.20;
    
    contract HelloWorld {
    
        // ✅ 状态变量 strVar，初始值为 "hello world"
        string strVar = "hello world";
    
        // ✅ 定义结构体 Info，包含 phrase(短语)、id(编号)、addr(调用者地址)
        struct Info {
            string phrase;
            uint256 id;
            address addr;
        }
    
        // ✅ 定义结构体数组 infos，用于保存所有 Info
        Info[] infos;
    
        // ✅ 查询函数 sayHelloWorld
        // 根据传入的 id 在 infos 中查询 phrase，否则返回默认 strVar
        function sayHelloWorld(uint256 _id) public view returns(string memory) {
            for (uint256 i = 0; i < infos.length; i++) {
                if (infos[i].id == _id) {
                    return addinfo(infos[i].phrase);
                }
            }
            return addinfo(strVar);
        }
    
        // ✅ 设置函数 setHelloWorld
        // 将外部传入的 phrase 和 id 封装为 Info 结构体，并添加到 infos 数组
        function setHelloWorld(string memory newstrVar, uint _id) public {
            Info memory info = Info(newstrVar, _id, msg.sender);
            infos.push(info);
        }
    
        // ✅ 内部函数 addinfo
        // 拼接传入字符串和固定后缀
        function addinfo(string memory HelloWorldstr) internal pure returns(string memory) {
            return string.concat(HelloWorldstr, ",from Von's Smart Contract");
        }
    
    }

🔍 本课新知识讲解
  
  1️⃣ struct（结构体）
    自定义复合数据类型，将不同变量封装为一个整体。

    例如 Info 结构体封装：

    phrase：短语 (string)

    id：编号 (uint256)

    addr：以太坊地址 (address)

2️⃣ 动态数组 vs. 定长数组
    类型	声明方式	特点
    动态数组	Info[] infos;	长度不固定，初始为 0，可使用 push 增长
    定长数组	Info[5] infos;	长度固定为 5，在声明时确定，无法增加或减少元素

✅ 【常见疑问】
    Q: infos 中是否在声明时就确定数量？

    A:  
    动态数组 在声明 Info[] infos; 时，仅定义了 数组类型，长度默认为 0，没有任何元素。
    
    只有调用 setHelloWorld 时，才会 push 添加结构体元素到 infos。

3️⃣ infos 数组执行流程
| 步骤                  | infos 数组长度 |
| ------------------- | ---------- |
| 部署合约                | 0（空数组）     |
| 第一次调用 setHelloWorld | 1          |
| 第二次调用 setHelloWorld | 2          |
| ...                 | 持续增长       |


✅ 关键总结：

      infos 是 一个动态数组，
      初始为空，
      每次调用 setHelloWorld，会 往数组里添加一个新的结构体元素。

4️⃣ msg.sender
      
      Solidity 全局变量
      
      记录调用当前函数的用户地址
      
      用于：
          
          记录用户
          
          权限控制
          
          转账接收者/发送者

5️⃣ memory 与 storage
| 关键字      | 作用              | 场景                   |
| -------- | --------------- | -------------------- |
| memory   | 临时变量，只在函数执行期间存在 | 函数参数、临时结构体           |
| storage  | 永久存储在区块链上       | 状态变量                 |
| calldata | 只读输入参数          | external 函数参数，更省 gas |

6️⃣ for 循环
    与 C 语言相同，用于遍历数组。

      solidity
      复制
      编辑
      for (uint256 i = 0; i < infos.length; i++) {
          ...
      }
🔑 7. 数组数量限制
    若希望限制动态数组长度，可添加 require：

      solidity
      复制
      编辑
      require(infos.length < 100, "数组已达到最大长度");
🧠 结构体数组访问拆解
  例如：

    solidity
    infos[i].id
✅ 含义：

  infos ：结构体数组
  
  infos[i] ：数组中第 i 个结构体
  
  infos[i].id ：第 i 个结构体的 id 字段

💡 简单比喻
infos = 一排盒子（数组）
infos[i] = 第 i 个盒子（结构体）
infos[i].id = 盒子上的编号（id 字段）

🚀 练习拓展
修改 sayHelloWorld，返回 phrase 与调用者 address（可使用 event 或 struct 返回）。

实现删除 infos 中指定 id 的结构体元素。

为 setHelloWorld 添加 require 判断，避免 id 重复。

🎯 本课总结
本课收获
  ✅ struct 结构体定义与使用
  ✅ 动态数组与定长数组区别
  ✅ msg.sender 的作用
  ✅ for 循环遍历结构体数组
  ✅ memory/storage/calldata 概念
  ✅ infos 数组数量与 push 增长机制


