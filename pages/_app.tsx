import { AppProps } from 'next/app'
import '@/styles/global.css'
import DeleteQuestion from '@/components/DeleteQuestion'
import { Provider } from 'react-redux'
import { store } from '@/store'
import { useEffect } from 'react'
import { checkWallet } from '@/services/blockChain'
import 'react-toastify/dist/ReactToastify.css'
import { ToastContainer } from 'react-toastify'

export default function MyApp({ Component, pageProps }: AppProps) {
  useEffect(() => {
    checkWallet()
  }, [])

  return (
    <Provider store={store}>
      <Component {...pageProps} />
      <DeleteQuestion />

      <ToastContainer
        position="bottom-center"
        autoClose={5000}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
        theme="dark"
      />
    </Provider>
  )
}
