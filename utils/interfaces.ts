export interface TagsProps {
  tags: string[]
}

export interface TruncateProps {
  text: string
  startChars: number
  endChars: number
  maxLength: number
}

export interface AnswerProp {
  id: number
  qid: number
  comment: string
  owner: string
  deleted: boolean
  updated: number
  created: number
}

export interface QuestionProp {
  id: number
  title: string
  description: string
  owner: string
  winner: string
  paidout: boolean
  deleted: boolean
  updated: number
  created: number
  answers: number
  tags: string[]
  prize: number
}

export interface GlobalState {
  wallet: string | null
  owner: string | null
  questions: QuestionProp[]
  question: QuestionProp | null
  addQuestionModal: string
  updateQuestionModal: string
  deleteQuestionModal: string
  addAnswerModal: string
  answers: AnswerProp[]
}

export interface RootState {
  globalStates: GlobalState
}

export interface QuestionParams {
  title: string
  description: string
  tags: string
  prize: number | null
}
