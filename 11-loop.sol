// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Loop {
    uint256 public a;
    uint256 public b;

    function loop() public {
        // for loop
        for (uint256 i = 0; i < 10; i++) {
            if (i == 3) {
                // Skip to next iteration with continue
                a = i;
                continue;
            }
            if (i == 5) {
                // Exit loop with break
                a = i;
                break;
            }
        }

        // while loop
        uint256 j;
        while (j < 10) {
            j++;
            b=j;
        }
    }
}