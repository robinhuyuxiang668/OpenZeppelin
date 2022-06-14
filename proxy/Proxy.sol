// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

/**
 * @dev 这个抽象合约提供了一个回退函数，它使用 EVM 将所有调用委托给另一个合约
  *指令`delegatecall`。 我们将第二个合约称为代理背后的_实现_，它必须
  * 通过覆盖虚拟 {_implementation} 函数来指定。
  *
  * 此外，可以通过 {_fallback} 函数手动触发对实现的委托，或
  * 通过 {_delegate} 函数实现不同的合约。
  *
  * 委托调用的成功和返回数据将返回给代理的调用者
  */
abstract contract Proxy {
    /**
     * @dev 将当前调用委托给implementation。
            此函数不返回其内部调用站点，它将直接返回给外部调用者.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // 复制 msg.data。 我们在这个内联汇编中完全控制了内存
             // 阻塞，因为它不会返回 Solidity 代码。 我们覆盖
             // 内存位置 0 的 Solidity 便签本.
            calldatacopy(0, 0, calldatasize())

            // 调用实现。
             // out 和 outsize 为 0，因为我们还不知道大小.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev 这是一个应该被覆盖的虚函数，因此它返回回退函数_fallback应该委托的地址.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev 将当前调用委托给 . 返回的地址_implementation()。

此函数不返回其内部调用站点，它将直接返回给外部调用者.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev 将调用委托给 . 返回的地址的后备函数_implementation()。
     如果合约中没有其他函数与调用数据匹配，则将运行.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev 将调用委托给 . 返回的地址的后备函数_implementation()。如果呼叫数据为空，将运行.
     */
    receive() external payable virtual {
        _fallback();
    }

    /**
     * @dev 在回退到实现之前调用的钩子。可以作为手动_fallback 调用的一部分发生，
     也可以作为 Solidityfallback或receive函数的一部分发生。
     如果被覆盖应该调用super._beforeFallback().
     */
    function _beforeFallback() internal virtual {}
}
