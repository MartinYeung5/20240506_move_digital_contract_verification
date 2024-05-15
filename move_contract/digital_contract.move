module digital_contract::digital_contract_20240507 {

    //==============================================================================================
    // Dependencies
    //==============================================================================================
    use sui::event;
    use sui::sui::SUI;
    use std::string::{Self, String};
    use sui::{coin, balance::{Self, Balance}};

    //==============================================================================================
    // Error codes 
    //==============================================================================================
    // error code for not contract owner
    const ENotContractOwner: u64 = 1;
    // error code for invalid withdrawal amount
    const EInvalidWithdrawalAmount: u64 = 2;
    // error code for insufficient payment
    const EInsufficientPayment: u64 = 3;
    // error code for invalid task id
    const EInvalidTaskId: u64 = 4;
    // error code for invalid budget
    const EInvalidBudget: u64 = 5;

    //==============================================================================================
    // Structs 
    //==============================================================================================

    /*
        The contract struct represents a digital contract in the contract hub. 
        A contract is a global shared object that is managed by the contract owner. 
        The contract owner is designated by the ownership of the contract owner capability. 
        @param id - The object id of the contract object.
        @param contract_owner_cap - The object id of the contract owner capability.
        @param balance - The balance of SUI coins in the contract.
        @param tasks - The tasks in the contract.
        @param task_count - The number of tasks in the contract.
    */
	public struct Contract has key {
		id: UID,
        contract_owner_cap: ID,
		balance: Balance<SUI>,
		tasks: vector<Task>, // will have many tasks
        task_count: u64,
        contract_hash: String // use the hashed data for the contract content and will update when the contract data is updated
	}

    /*
        one contract can have zero to many tasks
        @param id - The object id of the task object.
        @param contract - The object id of the contract.
        @param service_provider - The address of service provider for the task.
        @param title - The title of the task.
        @param description - The description of the task.
        @param budget - The budget of the task.
        @param category - The category of the task.
        @param status - The status of the task.
    */

    public struct Task has store {
		id: u64,
        contract: ID,
		service_provider: u64, //will have one service_provider
		title: String,
		description: String,
		budget: u64,
        category: String,
        status: String
	}

    /*
        Event to be emitted when a task is added to a contract.
        @param contract_id - The id of the contract object.
        @param task_id - The id of the task object.
    */
    public struct TaskAdded has copy, drop {
        contract_id: ID,
        task_id: u64,
    }


    /*
        The contract owner capability struct represents the ownership of a contract. 
        The contract owner capability is a object that is owned by the contract owner 
        and is used to manage the contract.
        @param id - The object id of the contract owner capability object.
        @param contract - The object id of the contract object.
    */
    /*  contract owner can sell/transfer their contract to other serivce providers/owners
        therefore, we need to set the cap for the owner to transfer their cap to others
    */
    public struct ContractOwnerCapability has key {
        id: UID,
        contract: ID,
    }

    /*
        The service provider struct represents the role in a contract. 
        A service provider is a task's owner.
        @param id - The id of the service provider object.
        @param address - The address of the service provider.
        @param service_provider_name - The name of the service provider.
        @param description - The description of the service provider.
        @param category - The category of the service provider.
    */
    public struct ServiceProvider has store {
		id: u64,
        address: u64,
		service_provider_name: String,
		description: String,
        category: String
	}

    /*
        The finished task struct represents a finished task record. 
        @param id - The object id of the finsihed task object.
        @param contract_id - The object id of the contract object.
        @param service_provider_id - The id of the service provider object.
    */
    public struct FinishedTask has store {
        id: UID,
        contract_id: ID, 
        service_provider_id: u64
    }

    //==============================================================================================
    // Event structs
    //==============================================================================================

    /*
        Event to be emitted when a contract is created.
        @param contract_id - The id of the contract object.
        @param contract_owner_cap_id - The id of the contract owner capability object.
    */
    public struct ContractCreatedEvent has copy, drop {
        contract_id: ID,
        contract_owner_cap_id: ID,
    }

    /*
        Event to be emitted when task is added to a contract.
        @param contract_id - The id of the contract object.
        @param task_id - The id of the task object.
    */
    public struct TaskAddedEvent has copy, drop {
        contract_id: ID,
        task_id: u64,
    }

    /*
        Event to be emitted when service provider is added to a contract.
        @param contract_id - The id of the contract object.
        @param service_provider_id - The id of the service provider object.
    */
    public struct ServiceProviderAddedEvent has copy, drop {
        contract_id: ID,
        service_provider_id: u64,
    }

    /*
        Event to be emitted when a user prepay the task budget from contract.
        @param contract_id - The id of the contract object.
        @param task_id - The id of the task object.
        @param budget - The budget of task.
        @param user_address - The address of the user of the task.
        @param service_provider_address - The address of the service provider of the task.
        @param owner - The address of the owner of the contract.
        Remark:
        * will not pay the fee directly to the service provider
        * when the task is completed, service provider can have the right to get the fee
    */
    public struct PrePaidTaskEvent has copy, drop {
        contract_id: ID,
        task_id: u64,
        budget: u64,
        user_address: address,
        service_provider_address: address,
        owner: address
    }

    /*
        Event to be emitted when task is finished.
        @param contract_id - The id of the contract object.
        @param task_id - The id of the task object.
        @param user_address - The address of the user.
        @param service_provider_address - The address of the task's service provider.
    */
    // ** owner can collection commission fee at final
    // ** user will pay the budget to service provider who owns the task, and contract owner will get the commission fee from each tasks
    // Question: 
    public struct FinishedTaskEvent has copy, drop {
        contract_id: ID,
        task_id: u64, 
        user_address: address,
        service_provider_address: address
    }

    /*
        Event to be emitted when a contract owner withdraws from their contract.
        @param contract_id - The id of the contract object.
        @param amount - The amount withdrawn.
        @param owner - The address of the owner of the withdrawal.
    */
    public struct ContractWithdrawalEvent has copy, drop {
        contract_id: ID,
        amount: u64,
        owner: address
    }

    //==============================================================================================
    // Functions
    //==============================================================================================

	/*
        Creates a new contract for the owner and emits a ContractCreatedEvent event.
        @param owner - The address of the owner of the contract.
        @param ctx - The transaction context.
	*/
	public fun create_contract(owner: address, contract_hash: String, ctx: &mut TxContext) {
        let contract_uid = object::new(ctx); 
        let contract_owner_cap_uid = object::new(ctx); 

        let contract_id = object::uid_to_inner(&contract_uid);
        let contract_owner_cap_id = object::uid_to_inner(&contract_owner_cap_uid);

        transfer::transfer(ContractOwnerCapability {
            id: contract_owner_cap_uid,
            contract: contract_id
         }, owner);

        transfer::share_object(Contract {
            id: contract_uid,
            contract_owner_cap: contract_owner_cap_id,
            balance: balance::zero<SUI>(),
		    tasks: vector::empty(),
            task_count: 0,
            contract_hash: contract_hash
        });

        event::emit(ContractCreatedEvent{
           contract_id, 
           contract_owner_cap_id
        })
	}

    /*
        Adds a new task to the contract and emits an TaskAdded event. 
        Abort if the contract owner capability does not match.
        @param contract - The contract to add the task to.
        @param contract_owner_cap - The contract owner capability of the contract.
        @param service_provider - The ID of the service provider.
        @param title - The title of the task.
        @param description - The description of the task.
        @param budget - The price of the task.
        @param category - The category of the task.
        @param ctx - The transaction context.
    */
    public fun add_task(
        contract: &mut Contract,
        contract_owner_cap: &ContractOwnerCapability, 
        service_provider: u64,
        title: vector<u8>,
        description: vector<u8>,
        budget: u64, 
        category: String,
        status: String
    ) {
        assert!(contract.contract_owner_cap== object::uid_to_inner(&contract_owner_cap.id), ENotContractOwner);
        assert!(budget>0, EInvalidBudget);

        let task_id = contract.tasks.length();

        let task = Task{
            id: task_id,
            contract: object::uid_to_inner(&contract.id),
            service_provider: service_provider,
            title: string::utf8(title),
            description:string::utf8(description),
            budget: budget,
            category: category,
            status: status,
        };

        contract.tasks.push_back(task);
        contract.task_count = contract.task_count + 1;

        event::emit(TaskAdded{
            contract_id: contract_owner_cap.contract, 
            task_id: task_id
        });
    }

    /*
        Pay for task from the contract and emits an PrePaidTaskEvent. 
        Abort if the task id is invalid /
        the payment coin is insufficient
        @param contract - The contract to have the task.
        @param task_id - The id of the task to pay.
        @param user_address - The address of the user who pay for the task.
        @param service_provider_address - The address of the service provider of the task.
        @param owner - The address of the owner of the contract.
        @param payment_coin - The payment coin for the task.
        @param ctx - The transaction context.
    */
    public fun pay_for_task(
        contract: &mut Contract, 
        task_id: u64,
        user_address: address,
        service_provider_address: address,
        payment_coin: &mut coin::Coin<SUI>,
        owner: address,
        ctx: &mut TxContext
    ) {
        assert!(task_id <= contract.tasks.length(), EInvalidTaskId);
        
        let task = &mut contract.tasks[task_id];
        let value = payment_coin.value();
        let task_budget = task.budget;
        assert!(value >= task_budget, EInsufficientPayment);

        let paid = payment_coin.split(task_budget, ctx);

        coin::put(&mut contract.balance, paid);

        event::emit(PrePaidTaskEvent {
            contract_id: object::uid_to_inner(&contract.id),
            task_id: task_id,
            budget: task_budget,
            user_address: user_address,
            service_provider_address: service_provider_address,
            owner: owner,
        });
        // issue: need to update task status !!!!
        // vector::borrow_mut(&mut contract.tasks, task_id).status = paid;
    }

    /*
        Withdraws SUI from the contract to the owner and emits a ContractWithdrawal event. 
        Abort if the contract owner capability does not match the contract or if the amount is invalid.
        All tasks should be completed.
        
        @param contract - The contract to withdraw from.
        @param contract_owner_cap - The contract owner capability of the contract.
        @param amount - The amount to withdraw.
        @param owner - The address of the owner of the withdrawal.
        @param ctx - The transaction context.
    */
    public fun withdraw_from_contract(
        contract: &mut Contract,
        contract_owner_cap: &ContractOwnerCapability,
        amount: u64,
        owner: address,
        ctx: &mut TxContext
    ) {
        
        assert!(contract.contract_owner_cap== object::uid_to_inner(&contract_owner_cap.id), ENotContractOwner);
        
        assert!(amount > 0 && amount <= contract.balance.value(), EInvalidWithdrawalAmount);

        let take_coin = coin::take(&mut contract.balance, amount, ctx);
        
        transfer::public_transfer(take_coin, owner);
        
        event::emit(ContractWithdrawalEvent{
            contract_id: object::uid_to_inner(&contract.id),
            amount: amount,
            owner: owner
        });
    }

    //==============================================================================================
    // Getters
    //==============================================================================================

    // getters for the contract struct
    public fun get_contract_uid(contract: &Contract): &UID {
        &contract.id
    }

    public fun get_contract_owner_cap(contract: &Contract): ID {
        contract.contract_owner_cap
    }

    public fun get_contract_balance(contract: &Contract):  &Balance<SUI> {
        &contract.balance
    }

    public fun get_contract_tasks(contract: &Contract):  &vector<Task> {
        &contract.tasks
    }

    public fun get_contract_task_count(contract: &Contract): u64{
        contract.task_count
    }

    // getters for the contract owner capability struct
    public fun get_contract_owner_cap_uid(contract_owner_cap: &ContractOwnerCapability): &UID {
        &contract_owner_cap.id
    }

    public fun get_contract_owner_cap_contract(contract_owner_cap: &ContractOwnerCapability): ID {
        contract_owner_cap.contract
    }

    // getters for the task struct
    public fun get_task_id(task: &Task): u64 {
        task.id
    }

    public fun get_task_title(task: &Task): String {
        task.title
    }

    public fun get_task_description(task: &Task): String {
        task.description
    }

    public fun get_task_budget(task: &Task): u64{
        task.budget
    }

    public fun get_task_service_provider(task: &Task): u64{
        task.service_provider
    }

    public fun get_task_status(task: &Task): String{
        task.status
    }

    public fun get_task_category(task: &Task): String{
        task.category
    }

    // getters for the payment for task struct
    public fun get_pay_for_task_contract_id(paid_task: &FinishedTaskEvent): ID {
        paid_task.contract_id
    }

    public fun get_pay_for_task_task_id(paid_task: &FinishedTaskEvent): u64 {    
        paid_task.task_id
    }

    public fun get_pay_for_service_provider_address(paid_task: &FinishedTaskEvent): address {    
        paid_task.service_provider_address
    }

    public fun get_pay_for_user_address(paid_task: &FinishedTaskEvent): address {    
        paid_task.user_address
    }

    // getters for the service provider struct
    public fun get_service_provider_contract_id(service_provider: &ServiceProviderAddedEvent): ID {    
        service_provider.contract_id
    }

    public fun get_service_provider_service_provider_id(service_provider: &ServiceProviderAddedEvent): u64 {    
        service_provider.service_provider_id
    }

}