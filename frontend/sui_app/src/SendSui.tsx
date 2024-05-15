import { useSignAndExecuteTransactionBlock } from '@mysten/dapp-kit';
import { TransactionBlock } from '@mysten/sui.js/transactions';

export function SendSui() {
 const { mutateAsync: signAndExecuteTransactionBlock } = useSignAndExecuteTransactionBlock();

 function sendMessage() {
  const txb = new TransactionBlock();

  const coin = txb.splitCoins(txb.gas, [100000000]);
  txb.transferObjects([coin], 'Ox...');

  signAndExecuteTransactionBlock({
   transactionBlock: txb,
  }).then(async (result) => {
   alert('Sui sent successfully');
  });
 }

 return <button onClick={() => sendMessage()}>Send Token to others !</button>;
}