## Discription

#### Project repo
https://github.com/MartinYeung5/20240506_move_digital_contract_verification

#### Concept
1. develop a platform for user to build the digital contract with different parties
2. develop the zk verification function for the contract
3. contract audit with AI application

#### Structure
1. smart contract - using Move
    * 1.1 contract: digital_contract - will use for reacord the hashed data of digital contract and it will be used to do verification
    * 1.2 contract: multisig2 (testing)- will handle the multi sig function
    * 1.3 zk_function (testing)- will handle zk verification
2. zk verification - user will input something to verify the digital contract/ personal identity. 
    * 2.1 standard: Groth16 (testing)
    * 2.2 backend: Rust
    * 2.3 frontend: tarui + Nextjs : will pass the verification 
    * 2.4 smart contract: zk_function
3. frontend - Nextjs
4. database - mongoDb

##### Problem
* zk verification issue: can't use the dependency of ark-circom within tarui
* zklogin + wallet login can't combined together

##### Process
1. 20240506
* repo setup
* smart contract development

2. 20240507
* frontend section: complete 1 function
    * user can get the free token by one step on front page
* contract section: 
    * blueprint is done, but still improve some specific parts

3. 20240508
* frontend section:
    * zklogin (with google account) - still testing
* contract section:
    * finshed the update (build successfully)
    * desgining the test case


#### References
* https://learnblockchain.cn/article/7478
* UID, ID, Address
