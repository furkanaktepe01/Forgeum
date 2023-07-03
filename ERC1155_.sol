//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155_ is ERC1155 {

    address public immutable forger;
    uint public immutable highestFreeId;
    uint public immutable cooldown;
    uint public lock;

    constructor(
        string memory uri_,
        address forger_,
        uint highestFreeId_,
        uint cooldown_
    ) ERC1155(uri_) {

        forger = forger_;
        highestFreeId = highestFreeId_;
        cooldown = cooldown_;
    }

    function trade(uint inId, uint outId, uint amount) public {

        require(outId <= highestFreeId, "OutId cant exceed highestFreeId.");

        _burn(msg.sender, inId, amount);

        _mint(msg.sender, outId, amount, "");
    }

    function mint(uint id, uint amount, bytes memory data) public {

        require(id <= highestFreeId, "Id cant exceed highestFreeId.");

        _lock();

        _mint(msg.sender, id, amount, data);
    }

    function burn(uint id, uint amount) public {

        _burn(msg.sender, id, amount);
    }

    function mintBatch(
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) public _mintable(to, ids) {

        _mintBatch(to, ids, amounts, data);
    }

    function burnBatch(
        address from,
        uint[] memory ids,
        uint[] memory amounts
    ) public _burnable(from) {

        _burnBatch(from, ids, amounts);
    }

    function _checkIds(uint[] memory ids) private view returns (bool) {

        for (uint i = 0; i < ids.length; i++) {

            if (ids[i] > highestFreeId) {
                
                return false;
            }
        }

        return true;
    }

    function _lock() private {

        require(block.timestamp >= lock, "Cant mint during cooldown.");

        lock = block.timestamp + cooldown;
    }

    modifier _mintable(address to, uint[] memory ids) {

        if (msg.sender != forger) {

            _lock();
            
            require(msg.sender == to, "One can only mint to oneself.");

            require(_checkIds(ids), "Id cant exceed highestFreeId.");
        }

        _;
    }

    modifier _burnable(address from) {

        if (msg.sender != forger) {

            require(msg.sender == from, "One can only burn from oneself.");
        }

        _;
    }
}
