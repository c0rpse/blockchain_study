### 拜占庭将军 
	https://baike.baidu.com/item/%E6%8B%9C%E5%8D%A0%E5%BA%AD%E5%B0%86%E5%86%9B%E9%97%AE%E9%A2%98/265656?fr=aladdin
### 女巫攻击
	https://www.jianshu.com/p/078307c6f63
### 比特币系统脚本语言的限制
- 缺少图灵完备性
    这就是说，尽管比特币脚本语言可以支持多种计算，但是它不能支持所有的计算。最主要的缺失是循环语句。不支持循环语句的目的是避免交易确认时出现无限循环。理论上，对于脚本程序员来说，这是可以克服的障碍，因为任何循环都可以用多次重复if 语句的方式来模拟，但是这样做会导致脚本空间利用上的低效率，例如，实施一个替代的椭圆曲线签名算法可能将需要256次重复的乘法，而每次都需要单独编码。
- 价值盲（Value-blindness）
    UTXO脚本不能为账户的取款额度提供精细的控制。例如，预言机合约（oracle 
    contract）的一个强大应用是对冲合约，A和B各自向对冲合约中发送价值1000美元的比特币，30天以后，脚本向A发送价值1000美元的比特币，向B发送剩余的比特币。虽然实现对冲合约需要一个预言机（oracle）决定一比特币值多少美元，但是与现在完全中心化的解决方案相比，这一机制已经在减少信任和基础设施方面有了巨大的进步。然而，因为UTXO是不可分割的，为实现此合约，唯一的方法是非常低效地采用许多有不同面值的UTXO（例如对应于最大为30的每个k，有一个2^k的UTXO)并使预言机挑出正确的UTXO发送给A和B。
- 缺少状态 
UTXO只能是已花费或者未花费状态，这就没有给需要任何其它内部状态的多阶段合约或者脚本留出生存空间。这使得实现多阶段期权合约、去中心化的交换要约或者两阶段加密承诺协议（对确保计算奖励非常必要）非常困难。这也意味着UTXO只能用于建立简单的、一次性的合约，而不是例如去中心化组织这样的有着更加复杂的状态的合约，使得元协议难以实现。二元状态与价值盲结合在一起意味着另一个重要的应用-取款限额-是不可能实现的。
- 区块链盲（Blockchain-blindness）
    UTXO看不到区块链的数据，例如随机数和上一个区块的哈希。这一缺陷剥夺了脚本语言所拥有的基于随机性的潜在价值，严重地限制了博彩等其它领域应用。
### MPT 默克尔帕特里夏树 
    https://github.com/ethereum/wiki/wiki/Patricia-Tree
    http://me.tryblockchain.org/Ethereum-MerklePatriciaTree.html
    默克尔树解决数据校验问题，而帕特里夏树解决了效率问题。
### MPT树构建的个人总结
网络上关于MPT树如何构建的翻译文章要么语焉不详，要么出现错误，自己做了分析并记录如下：

    帕特里夏树是经过改造的Trie树，是基于字符来存储路径的.
    帕特里夏树存储的要点如下：
        如果key长度>1,那么该节点无法用分支节点表示，只能用其它节点表示；
        出现结束节点，如无其它后续节点，使用叶子节点表示，否则使用分支节点表示；
        没有结束节点，且prefix只有一个，使用扩展节点。
    
    <64 6f> : 'verb'
    <64 6f 67> : 'puppy'
    <64 6f 67 65> : 'coin'
    <68 6f 72 73 65> : 'stallion'
    给定上述key/value节点，给出如下构建步骤:
    1. 首先尝试寻找所有给定节点key的最长前缀，得到prefix=6.根据path编码规则，prefix长度奇数标记odd=1，结束标记term=0，那么root节点的key为<16>,
    由于不是结束节点，key字符长度为1且key只有一个值，那么该节点不必使用分枝节点表示，应使用扩展节点，value为NodeA;
    Root: [<16>, NodeA]
    2. 为了确定NodeA的节点类型，首先继续寻找prefix，发现所有key/value对的第二个字符去重集合为[4、8],
    那么很显然，NodeA需要进行分叉，在index为4、8的位置填入后续节点的地址，value置空；
    NodeA: [<>,<>,<>,<>,NodeB,<>,<>,<>,NodeC,<>,<>,<>,<>,<>,<>,<>,NULL]
    3. 由于没有其它kv对的路径与NodeC相同，那么NodeC成为叶子节点，key=<20 6f 72 73 65>, value="stallion"
    .key第一个字符=20是因为path编码决定的，odd=0, term=1, 第一个半字节nipple=0x10 + [0]=20.
    NodeC: [<20 6f 72 73 65>, "stallion"]
    4. 对于NodeB，发现prefix=6f,长度>1,不可能是一个分支节点，有三个后续节点，那么该节点只能为扩展节点,key=006f,value=NodeD;
    NodeB: [<00 6f>, NodeD]
    5. 此时出现了结束节点，且还有后续节点，那么键值对节点无法表示，需要使用分支节点，由于分支节点需要位置且分支节点prefix长度只能为1，此时的位置参数均为6,
    因此位置6应为后续节点NodeE；
    NodeD: [<>,<>,<>,<>,<>,<>,NodeE,<>,<>,<>,<>,<>,<>,<>,<>,<>,"verb"]
    6. 继续寻找，prefix=7，有后续节点没有结束节点，那么NodeE不能使用叶子节点，需要使用扩展节点。key=17.
    NodeE: [<17>, NodeF]
    7. 此时出现结束节点，且仍有后续节点，不能使用叶子节点，需要使用分支节点存储结束节点的值，并指明后续节点位置,此时prefix=6,位置为6。
    NodeF: [<>,<>,<>,<>,<>,<>,NodeG,<>,<>,<>,<>,<>,<>,<>,<>,<>,"puppy"]
    8.发现结束节点,prefix=5，应使用叶子节点表示,term=1, odd=1, key=0x11+[5]=35;
    NodeG: [<35>, "coin"]
    路径图如下:
    Root: [<16>, NodeA]
    NodeA: [<>,<>,<>,<>,NodeB,<>,<>,<>,NodeC,<>,<>,<>,<>,<>,<>,<>,NULL]
    NodeC: [<20 6f 72 73 65>, "stallion"]
    NodeB: [<00 6f>, NodeD]
    NodeD: [<>,<>,<>,<>,<>,<>,NodeE,<>,<>,<>,<>,<>,<>,<>,<>,<>,"verb"]
    NodeE: [<17>, NodeF]
    NodeF: [<>,<>,<>,<>,<>,<>,NodeG,<>,<>,<>,<>,<>,<>,<>,<>,<>,"puppy"]
    NodeG: [<35>, "coin"]

### UTXO的思考
- 一个用户的余额因此并不是作为一个数字储存起来的；而是用他占有的 UTXO 的总和计算出来的。
- 如果一个用户想要发送一笔交易，发送 X 个币到一个特定的地址，有时候，他们拥有的 UTXO 的一些子集组合起来面值恰好是 X，在这种情况下，他们可以创造一个交易：花费他们的 UTXO 并创造出一笔新的、价值 X 的 UTXO ，由目标地址占有。当这种完美的配对不可能的时候，用户就必须打包其和值 大于 X 的 UTXO 输入集合，并添加一笔拥有第二个目标地址的 UTXO ，称为“变更输出”，分配剩下的币到一个由他们自己控制的地址。
### 零知识证明（Zero Knowledge Proof, ZKP）
    ZKP意味着A可以向B证明，他知道特定的信息，而不必告诉对方自己具体知道些什么。
### PBFT 实用拜占庭容错
### 区块生产者数量
    在委托权益证明网络中，区块生产者数量是由该链的共识规则决定的。下面是一些最广为人知的委托权益证明链及其规定的生产者数量：

    - EOS: 21
    - BitShares: 101
    - Steemit: 21
    - Lisk: 101
    - Ark: 51