import { useCurrentAccount, useSignAndExecuteTransactionBlock } from '@mysten/dapp-kit';
import { TransactionBlock } from '@mysten/sui.js/transactions';


export function GetFreeCoin() {
    const { mutateAsync: signAndExecuteTransactionBlock } = useSignAndExecuteTransactionBlock();
    const account = useCurrentAccount();

    function sendMessage() {
        const txb = new TransactionBlock();

        // Object IDs can be passed to some methods like (transferObjects) directly
     //   txb.transferObjects(
     //       ['0xc9c9ff534a246d120d7787f2dfaebc852860feb9040f56056f14e3aab57fc131'], 
     //   'OxSomeAddress'
    //);
        // txb.object can be used anywhere an object is accepted
        //txb.transferObjects([txb.object('0xSomeObject')], 'OxSomeAddress');

        txb.moveCall({
            target: '0xb564841a2b36b9e350bb0bbde52ac34310e2f6b0eed2cd0efe76eeb53d88d399::faucetucoin::mint',
            // object IDs must be wrapped in moveCall arguments
            arguments: [
                txb.object('0x771e68e7128b906eb3072e7ab246a3a4380e9070a7f1b0b9f8f3a6f7644f879f'),
                txb.pure.u64(10),
                txb.pure.address(account?.address)
            ],
        });

        signAndExecuteTransactionBlock({ transactionBlock: txb })
        .then(async (result) => {
            alert('FUPC received successfully');
           })
        ;


    }

    return <button onClick={() => sendMessage()}>get free coin!</button>;
}