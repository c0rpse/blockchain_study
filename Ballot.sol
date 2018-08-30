pragma solidity ^0.4.11;

/// @title 委托投票
contract Ballot{
    // 公民
    struct Voter{
        uint weight;            // 权重
        bool voted;             // 是否已投票
        address delegate;       // 被被委托人
        uint vote;              // 投票提案的索引值
    }

    // 提案
    struct Proposal{
        bytes32 name;           // 提案名称
        uint voteCount;         // 得票数量
    }

    address public chairperson; //主席

    // 公民映射关系
    mapping(address => Voter) public voters;

    // 提案数组
    Proposal[] public proposals;

    // 构造
    // 设置主席、主席输入提案名字,初始化提案数组
    constructor() public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
    }
    // 主席添加提案
    function addProposal(bytes32 proposalName) public {
        require(chairperson == msg.sender, "Only chairperson can add proposal.");
        proposals.push(Proposal({
                name: proposalName,
                voteCount: 0
                }));
    }

    // 获取提案票数
    function getProposalVoteCount(uint proposalIndex) public view returns (uint voteCount){
        voteCount = proposals[proposalIndex].voteCount;
    }

    //主席授权公民对某项提案的投票权
    function giveRightToVoter(address voter) public {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    // 公民将投票权委托给其它公民
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        // 委托可以传递，需要放置出现委托环造成死循环
        // 需要检查to的最终委托公民，并将该公民设置为to
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        // 如果被委托人已经投票，直接增加对应提案的票数
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }

    }

    // 投票
    function vote(uint proposalIndex) public {
        // 获取投票人
        Voter storage sender = voters[msg.sender];
        //
        require(!sender.voted, "Already voted.");

        sender.voted = true;
        sender.vote = proposalIndex;
        // 如果 `proposal` 超过了数组的范围，则会自动抛出异常，并恢复所有的改动
        proposals[proposalIndex].voteCount += sender.weight;
    }

    // 获胜提案序号
    // view用于承诺不修改合约状态
    function winnerProposal() public view returns (uint winnerProposal_) {
        uint winnerVoteCount = 0;
        for(uint i = 0; i < proposals.length; i++) {
            if(proposals[i].voteCount > winnerVoteCount) {
                winnerVoteCount = proposals[i].voteCount;
                winnerProposal_ = i;
            }
        }
    }

    // 获胜提案名称
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winnerProposal()].name;
    }

}