pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../FizzBuzz.sol";

contract FizzBuzzTest is DSTest{
    FizzBuzz internal fizzbuzz;

    function setUp() public {
        fizzbuzz = new FizzBuzz();
    }
    function test_returns_fizz_when_divisible_by_three() public {
            assertEq(fizzbuzz.fizzbuzz(3), "fizz");
        }

        function test_returns_fizz_when_divisible_by_five() public {
            assertEq(fizzbuzz.fizzbuzz(5), "buzz");
        }

    function test_returns_number_as_string_otherwise() public {
        assertEq(fizzbuzz.fizzbuzz(7), "7");
    }
}