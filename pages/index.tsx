import Head from 'next/head'
import Header from '@/components/Header'
import Banner from '@/components/Banner'
import Questions from '@/components/Questions'
import { QuestionProp } from '@/utils/interfaces'
import Empty from '@/components/Empty'
import AddQuestion from '@/components/AddQuestion'
import { getQuestions } from '@/services/blockChain'

export default function Home({ questions }: { questions: QuestionProp[] }) {
  return (
    <div>
      <Head>
        <title>Home</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="min-h-screen w-screen pb-20 radial-gradient">
        <Header />
        <Banner />
        {questions.length > 0 ? <Questions questions={questions} /> : <Empty />}
        <AddQuestion />
      </main>
    </div>
  )
}

export const getServerSideProps = async () => {
  const data = await getQuestions()
  return {
    props: { questions: JSON.parse(JSON.stringify(data)) },
  }
}
