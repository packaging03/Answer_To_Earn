import { store } from '@/store'
import { ethers } from 'ethers'
import { globalActions } from '@/store/globalSlices'
import address from '@/artifacts/contractAddress.json'
import abi from '@/artifacts/contracts/AnswerToEarn.sol/AnswerToEarn.json'
import { AnswerProp, QuestionParams, QuestionProp } from '@/utils/interfaces'

const { setWallet, setAnswers, setQuestion, setQuestions } = globalActions
const ContractAddress = address.address
const ContractAbi = abi.abi
let ethereum: any
let tx: any

if (typeof window !== 'undefined') {
  ethereum = (window as any).ethereum
}

const toWei = (num: number) => ethers.utils.parseEther(num.toString())
const fromWei = (num: number) => ethers.utils.formatEther(num)

const connectWallet = async () => {
  try {
    if (!ethereum) return reportError('Please install Metamask')
  } catch (error) {}
}

const reportError = (error: any) => {
  console.error(error)
}

export { connectWallet }
