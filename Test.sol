pragma solidity ^0.4.0;

contract Test {
    mapping(address => uint) public  voters;
    function multiply(uint a) public pure returns(uint d) {
        d = a * 7;
    }
    function addVoter(address voter_address, uint voter_index) public {
        voters[voter_address] = voter_index;
    }
    function getVoter(address voter_address) public view returns(uint voter_index){
        voter_index = voters[voter_address];
    }
}

