import { GlobalState, QuestionProp } from '@/utils/interfaces'
import { PayloadAction } from '@reduxjs/toolkit'

export const globalActions = {
  setWallet: (state: GlobalState, action: PayloadAction<string>) => {
    state.wallet = action.payload
  },
  setQuestions: (state: GlobalState, action: PayloadAction<QuestionProp[]>) => {
    state.questions = action.payload
  },
  setQuestion: (state: GlobalState, action: PayloadAction<QuestionProp>) => {
    state.question = action.payload
  },
}
