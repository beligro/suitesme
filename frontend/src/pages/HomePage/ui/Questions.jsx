import React, { useState } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import SectionWrapper from "../../../hoc/SectionWrapper.jsx";

const faqItems = [
    {
        question: 'КАК AI АНАЛИЗИРУЕТ МОЙ ТИПАЖ',
        answer: 'Искусственный интеллект (AI) анализирует типаж (форму лица) с помощью алгоритмов, которые обрабатывают изображения.',
    },
    {
        question: 'МОГУ ЛИ Я ДОВЕРЯТЬ РЕЗУЛЬТАТАМ?',
        answer: 'Результаты основаны на данных, но окончательное решение всегда за вами.',
    },
    {
        question: 'ЧТО ДЕЛАТЬ, ЕСЛИ Я НЕ СОГЛАСНА С РЕЗУЛЬТАТОМ ТИПИРОВАНИЯ?',
        answer: 'Вы можете пройти анализ повторно или обсудить результат с экспертом.',
    },
    {
        question: 'МОЖНО ЛИ ОПЛАТИТЬ ЗАРУБЕЖНОЙ КАРТОЙ?',
        answer: 'Да, принимаем международные карты и способы оплаты.',
    },
];

const Questions = () => {
    const [openIndex, setOpenIndex] = useState(null);

    const toggle = (index) => {
        setOpenIndex(openIndex === index ? null : index);
    };

    return (
        <div className="w-full flex justify-center mt-32">
            <div className="lg:w-[1000px] w-full lg:bg-white bg-[#C2CED8] lg:p-0 px-5 py-7 flex flex-col gap-5">
                <p className="text-[25px]  font-unbounded lg:text-left text-center font-extrabold text-[#1B3C4D]">Ответы на вопросы</p>

                <div className="w-full">
                    {faqItems.map((item, index) => (
                        <div key={index} className="border-b w-full border-gray-300 py-8">
                            <button
                                onClick={() => toggle(index)}
                                className="flex justify-between items-center w-full text-left text-[#1B3C4D] lg:font-medium font-light text-[16px]"
                            >
                                <span>{item.question}</span>
                                {openIndex === index ? <ChevronUp size={26} /> : <ChevronDown size={26} />}
                            </button>
                            {openIndex === index && (
                                <div className="mt-6 text-gray-600 text-[15px]">{item.answer}</div>
                            )}
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default SectionWrapper(Questions , 'questions');