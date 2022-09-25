import "openzeppelin-contracts/contracts/utils/Strings.sol";

pragma solidity 0.8.10;

contract FizzBuzz {
    function fizzbuzz(uint256 n) public pure returns (string memory) {
        if(n%5 == 0 && n% 3 == 0){
            return "fizzbuzz";
        }
        if (n%5 == 0){
            return "buzz";
        }

        if (n% 3 == 0){
            return "fizz";
        }

        return Strings.toString(n);
    }
}