## Discription

#### Project repo
https://github.com/MartinYeung5/20240506_move_digital_contract_verification

#### Concept
1. Develop digital contract verification platform​.
2. User can create digital contract​ including generating digital version of paper contract and new digital contract​.
3. User can upload hashed digital contract to blockchain (without sensitive data)​.
4. User can sign digital contract online and can implement multisig.
5. User can verify contract and use ZKP to protect privacy including zkLogin​.
6. Project use AI to do contract audit in order to detect the risk from the contract and discovery the problem.

#### Structure
1. smart contract - using Move
    * 1.1 contract: digital_contract - will use for reacord the hashed data of digital contract and contract's task
    * 1.2 contract: multisig - will handle the multi sig function
    * 1.3 contract: zk_function - will handle zk verification
2. zk verification - user will input some argument(s) to verify the digital contract/ personal identity. 
    * 2.1 standard: Groth16
    * 2.2 backend: Rust
    * 2.3 frontend: tarui + Nextjs : will pass the verification to the move contract
    * 2.4 smart contract: zk_function
3. frontend - vite (react)

##### Process


#### References
