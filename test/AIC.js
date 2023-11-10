const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { parseUnits, parseEther } = require("ethers");

describe("CCIP", function () {
  async function deployOneYearLockFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const SrcMockCCIP = await ethers.getContractFactory("MockCCIP");
    const srcMockCCIP = await SrcMockCCIP.deploy(1);

    const DstMockCCIP = await ethers.getContractFactory("BasicMessageReceiver");
    const dstMockCCIP = await DstMockCCIP.deploy(srcMockCCIP.target);

    const SrcLZEndpointMock = await ethers.getContractFactory("LZEndpointMock");
    const srcLZEndpointMock = await SrcLZEndpointMock.deploy(1);

    const DstLZEndpointMock = await ethers.getContractFactory("LZEndpointMock");
    const dstLZEndpointMock = await DstLZEndpointMock.deploy(2);

    const AIC = await ethers.getContractFactory("AIC");
    const aic = await AIC.deploy();

    const GMPCCIP = await ethers.getContractFactory("GMPCCIP");
    const gmpCCIP = await GMPCCIP.deploy(srcMockCCIP.target);

    const GMPLayerZero = await ethers.getContractFactory("GMPLayerZero");
    const gmpLayerZero = await GMPLayerZero.deploy(srcLZEndpointMock.target);

    const DstGMPLayerZero = await ethers.getContractFactory("GMPLayerZero");
    const dstGMPLayerZero = await DstGMPLayerZero.deploy(
      dstLZEndpointMock.target
    );

    let mockEstimatedNativeFee = parseEther("0.001");
    let mockEstimatedZroFee = parseEther("0.00025");
    await srcLZEndpointMock.setEstimatedFees(
      mockEstimatedNativeFee,
      mockEstimatedZroFee
    );
    await dstLZEndpointMock.setEstimatedFees(
      mockEstimatedNativeFee,
      mockEstimatedZroFee
    );
    await gmpLayerZero.setTrustedRemote(2, dstGMPLayerZero.target);
    await gmpLayerZero.setMinDstGas(2, 1, parseUnits("1", 18));
    await dstGMPLayerZero.setTrustedRemote(1, gmpLayerZero.target);
    await srcLZEndpointMock.setDestLzEndpoint(
      dstGMPLayerZero.target,
      dstLZEndpointMock.target
    );
    await dstLZEndpointMock.setDestLzEndpoint(
      gmpLayerZero.target,
      srcLZEndpointMock.target
    );

    await aic.addGMPService(gmpLayerZero.target);
    await aic.addGMPService(gmpCCIP.target);

    return {
      owner,
      otherAccount,
      srcMockCCIP,
      dstMockCCIP,
      srcLZEndpointMock,
      dstLZEndpointMock,
      aic,
      gmpCCIP,
      gmpLayerZero,
      dstGMPLayerZero,
    };
  }

  describe("send messafe", function () {
    it("Should send message in lz", async function () {
      const { aic, dstGMPLayerZero } = await loadFixture(
        deployOneYearLockFixture
      );
      // console.log(await aic.gmpServices(0));
      // console.log(await gmpLayerZero.target)
      await aic.sendMessage("0x68656c6c6f20776f726c64", 2, 0, {
        value: parseEther("0.1"),
      });
      expect(await dstGMPLayerZero.lstmessage()).to.equal(
        "0x68656c6c6f20776f726c64"
      );
    });

    it.only("Should send message in CCIP", async function () {
      const { aic, srcMockCCIP, dstMockCCIP } = await loadFixture(
        deployOneYearLockFixture
      );
      // console.log(await aic.gmpServices(0));
      // console.log(await gmpLayerZero.target)
      await srcMockCCIP.setDstCCIP(2, dstMockCCIP.target);
      await aic.sendMessage("0x68656c6c6f20776f726c64", 2, 1, {
        value: parseEther("0.1"),
      });
      console.log((await dstMockCCIP.getLatestMessageDetails())[3]);
      expect((await dstMockCCIP.getLatestMessageDetails())[3]).to.equal(
        "0x68656c6c6f20776f726c64"
      );
    });
  });
});
