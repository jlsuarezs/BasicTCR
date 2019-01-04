var TCR = artifacts.require("contracts/tcr/TCR.sol");
var TCRToken = artifacts.require("contracts/tcr/TCRToken.sol");

contract('TCR', async function (accounts) {

    let tcr, token

    const listingName = "DemoListing"

    before(async () => {

      token = await TCRToken.new({from: accounts[0]})
      tcr = await TCR.new("Simple TCR", token.address, [100, 60, 60], {from: accounts[0]})

    })

    it("Should initialize name", async function () {

        const name = await tcr.name()
        assert.equal(name, "DemoTcr", "Names do not equal")

    })

    it("Should initialize token", async function () {

        const name = await token.name()
        assert.equal(name, "DemoToken", "The token name was not initialized")

    })

    it("Should initialize minDeposit", async function () {

        const minDeposit = await tcr.minDeposit()
        assert.equal(minDeposit, 100, "minDeposit was not initialized")

    })

    it("Should initialize commitStageLen", async function () {

        const commitStageLen = await tcr.commitStageLen()
        assert.equal(commitStageLen, 60, "commitStageLen was not initialized")

    })

    it("Should apply", async function () {

        await token.approve(tcr.address, 100, {
            from: accounts[0]
        })

        const applyListing = await tcr.apply(web3.fromAscii(listingName), 100, listingName, {
            from: accounts[0]
        })

        assert.equal(applyListing.logs[0].event, "_Application", "apply listing failed")

    })

})
