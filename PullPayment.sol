// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/PullPayment.sol)

pragma solidity ^0.8.0;

import "../utils/escrow/Escrow.sol";

/**
 * @dev 拉取支付策略的简单实现 ，其中支付合同不直接与接收方账户交互，接收方账户必须自行提取付款。

在安全方面，在发送以太币时，提取支付通常被认为是最佳实践。它可以防止接收者阻止执行，并消除重入问题.
 */
abstract contract PullPayment {
    Escrow private immutable _escrow;

    constructor() {
        _escrow = new Escrow();
    }

    /**
     * @dev 提取累积付款，将所有气体转发给收件人。
      *
      * 请注意，_any_ 帐户可以调用此函数，而不仅仅是 `payee`。
      * 这意味着不知道 `PullPayment` 协议的合约仍然可以
      * 通过单独的账户调用以这种方式接收资金
      * {withdrawPayments}。
      *
      * 警告：转发所有气体会打开重入漏洞的大门。
      * 确保您信任收件人，或者遵循
      * 检查-效果-交互模式或使用 {ReentrancyGuard}。
      *
      * @param payee 谁的付款将被撤回。
      *
      * 导致 `escrow` 发出 {Withdrawn} 事件.
     */
    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    /**
     * @dev Returns the payments owed to an address.
     * @param dest The creditor's address.
     */
    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    /**
     * @dev 由付款人调用以将发送的金额存储为要提取的信用。
        以这种方式发送的资金存储在中间Escrow合约中，
        因此不存在提款前花费的危险.
     *
     * @param dest The destination address of the funds.
     * @param amount The amount to transfer.
     *
     * Causes the `escrow` to emit a {Deposited} event.
     */
    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }
}
